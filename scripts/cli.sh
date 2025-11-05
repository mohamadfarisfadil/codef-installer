#!/usr/bin/env bash
set -e
[ -f /etc/codef/credentials.txt ] && . /etc/codef/credentials.txt

BOLD='\e[1m'; NC='\e[0m'

repair() {
  # repair minimal tanpa internet: rewrite config pakai kredensial
  [ -z "${PORT_NGINX:-}" ] && PORT_NGINX=8080
  [ -z "${PORT_APACHE:-}" ] && PORT_APACHE=8081
  WEB_ROOT="/var/www/codef/public"
  sudo mkdir -p "$WEB_ROOT"
  [ -f "$WEB_ROOT/index.html" ] || echo "<h1>CodeF OK</h1>" | sudo tee "$WEB_ROOT/index.html" >/dev/null
  PHPFPM=$(ls /run/php/php*-fpm.sock 2>/dev/null | head -n1); [ -S "${PHPFPM:-}" ] && FCGI="unix:$PHPFPM" || FCGI="127.0.0.1:9000"

  sudo tee /etc/nginx/sites-available/codef >/dev/null <<NGX
server { listen 0.0.0.0:${PORT_NGINX} default_server; server_name _; root ${WEB_ROOT};
  index index.php index.html index.htm;
  location / { try_files \$uri \$uri/ =404; }
  location ~ \.php$ { include snippets/fastcgi-php.conf; fastcgi_pass ${FCGI};
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; include fastcgi_params; } }
NGX
  sudo ln -sf /etc/nginx/sites-available/codef /etc/nginx/sites-enabled/codef
  sudo nginx -t && sudo systemctl restart nginx

  sudo grep -q "^Listen ${PORT_APACHE}$" /etc/apache2/ports.conf || echo "Listen ${PORT_APACHE}" | sudo tee -a /etc/apache2/ports.conf >/dev/null
  sudo tee /etc/apache2/sites-available/codef.conf >/dev/null <<APC
<VirtualHost 0.0.0.0:${PORT_APACHE}>
  DocumentRoot ${WEB_ROOT}
  <Directory ${WEB_ROOT}> Options Indexes FollowSymLinks AllowOverride All Require all granted </Directory>
</VirtualHost>
APC
  sudo a2ensite codef.conf >/dev/null 2>&1 || true
  sudo systemctl restart apache2 || true
}

menu(){
  clear
  echo -e "${BOLD}CodeF CLI${NC}"
  echo "LAN_IP=${LAN_IP:-?}  PUBLIC_IP=${PUBLIC_IP:-?}  NGINX=${PORT_NGINX:-8080}  APACHE=${PORT_APACHE:-8081}"
  echo " 1) Start  2) Stop  3) Restart  4) Status"
  echo " 5) Tampilkan URL  6) Repair (rewrite config)  7) Exit"
  read -rp "Pilih [1-7]: " C
  case "$C" in
    1) sudo systemctl start nginx apache2 || true ;;
    2) sudo systemctl stop  nginx apache2 || true ;;
    3) sudo systemctl restart nginx apache2 || true ;;
    4) systemctl --no-pager status nginx apache2 || true; read -rp "(enter) " _ ;;
    5) L=$(hostname -I | awk '{print $1}'); echo "NGINX : http://$L:${PORT_NGINX:-8080}"; echo "Apache: http://$L:${PORT_APACHE:-8081}"; read -rp "(enter) " _ ;;
    6) repair; read -rp "Repair selesai. (enter) " _ ;;
    7) exit 0 ;;
    *) ;;
  esac
}
while true; do menu; done
