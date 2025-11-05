#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"
load_credentials

WEB_ROOT="/var/www/codef/public"
FCGI_PASS="$(detect_phpfpm)"

# ===== NGINX =====
sudo tee /etc/nginx/sites-available/codef >/dev/null <<NGX
server {
    listen 0.0.0.0:${PORT_NGINX} default_server;
    server_name _;
    root ${WEB_ROOT};
    index index.php index.html index.htm;
    location / { try_files \$uri \$uri/ =404; }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass ${FCGI_PASS};
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
NGX
sudo rm -f /etc/nginx/sites-enabled/default || true
sudo ln -sf /etc/nginx/sites-available/codef /etc/nginx/sites-enabled/codef
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx >/dev/null

say "NGINX aktif di 0.0.0.0:${PORT_NGINX}"

# ===== APACHE =====
sudo grep -q "^Listen ${PORT_APACHE}$" /etc/apache2/ports.conf 2>/dev/null || echo "Listen ${PORT_APACHE}" | sudo tee -a /etc/apache2/ports.conf >/dev/null
sudo tee /etc/apache2/sites-available/codef.conf >/dev/null <<APC
<VirtualHost 0.0.0.0:${PORT_APACHE}>
    DocumentRoot ${WEB_ROOT}
    <Directory ${WEB_ROOT}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/codef_error.log
    CustomLog \${APACHE_LOG_DIR}/codef_access.log combined
</VirtualHost>
APC
sudo a2ensite codef.conf >/dev/null 2>&1 || true
sudo systemctl restart apache2 || true
sudo systemctl enable apache2 >/dev/null 2>&1 || true

LAN=$(hostname -I | awk '{print $1}')
PUB=$(curl -s https://api.ipify.org || echo "-")
say "Akses LAN  : http://${LAN}:${PORT_NGINX} (NGINX), http://${LAN}:${PORT_APACHE} (Apache)"
say "Akses Public (jika ada IP): http://${PUB}:${PORT_NGINX}"
