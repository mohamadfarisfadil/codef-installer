#!/usr/bin/env bash
set -e
. "$(dirname "$0")/common.sh"

load_credentials
WEB_ROOT="/var/www/codef/public"
PHPFPM_SOCK="$(detect_phpfpm_sock)"

# ===== NGINX di 0.0.0.0:PORT_NGINX
sudo tee /etc/nginx/sites-available/codef >/dev/null <<NGX
server {
    listen 0.0.0.0:${PORT_NGINX} default_server;
    server_name _;
    root ${WEB_ROOT};
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${PHPFPM_SOCK};
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

# ===== Apache di 0.0.0.0:PORT_APACHE
sudo grep -q "^Listen ${PORT_APACHE}$" /etc/apache2/ports.conf 2>/dev/null || echo "Listen ${PORT_APACHE}" | sudo tee -a /etc/apache2/ports.conf >/dev/null

sudo tee /etc/apache2/sites-available/codef.conf >/dev/null <<APC
<VirtualHost 0.0.0.0:${PORT_APACHE}>
    ServerAdmin admin@localhost
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

sudo a2ensite codef.conf >/dev/null || true
sudo systemctl restart apache2 || true
sudo systemctl enable apache2 >/dev/null || true

say "Apache aktif di 0.0.0.0:${PORT_APACHE}"

say "--- Informasi Akses ---"
LAN_IP=$(hostname -I | awk '{print $1}')
PUBLIC_IP=$(curl -s https://api.ipify.org || echo "-")
echo "LAN  : http://${LAN_IP}:${PORT_NGINX} (NGINX), http://${LAN_IP}:${PORT_APACHE} (Apache)"
echo "Public: http://${PUBLIC_IP}:${PORT_NGINX} (jika IP publik tersedia)"
echo "User : ${USERNAME}"
echo "Pass : ${PASSWORD}"
echo -e "\nTips: CTRL + klik pada link di terminal untuk membuka browser."
