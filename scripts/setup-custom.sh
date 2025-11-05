#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"
load_credentials

WEB_ROOT="/var/www/codef/public"
FCGI_PASS="$(detect_phpfpm)"

while true; do
  clear
  echo "Pilih fitur:"
  echo " 1) Aktifkan NGINX (0.0.0.0:${PORT_NGINX})"
  echo " 2) Aktifkan Apache (0.0.0.0:${PORT_APACHE})"
  echo " 3) Aktifkan keduanya (Multi-Server)"
  echo " 4) Selesai"
  read -rp "Pilih [1-4]: " P

  case "$P" in
    1)
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
      sudo nginx -t && sudo systemctl restart nginx && sudo systemctl enable nginx >/dev/null
      ;;
    2)
      sudo sed -i '/^Listen 8081$/d' /etc/apache2/ports.conf 2>/dev/null || true
      sudo grep -q "^Listen ${PORT_APACHE}$" /etc/apache2/ports.conf 2>/dev/null || echo "Listen ${PORT_APACHE}" | sudo tee -a /etc/apache2/ports.conf >/dev/null
      sudo tee /etc/apache2/sites-available/codef.conf >/dev/null <<APC
<VirtualHost 0.0.0.0:${PORT_APACHE}>
    DocumentRoot ${WEB_ROOT}
    <Directory ${WEB_ROOT}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
APC
      sudo a2ensite codef.conf >/dev/null 2>&1 || true
      sudo apachectl -t && sudo systemctl restart apache2 && sudo systemctl enable apache2 >/dev/null 2>&1 || true
      ;;
    3) "$0" <<< $'1\n4' >/dev/null || true; "$0" <<< $'2\n4' >/dev/null || true ;;
    4) break ;;
    *) echo "Pilihan tidak valid"; sleep 1 ;;
  esac
done
