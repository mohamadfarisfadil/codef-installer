#!/usr/bin/env bash
set -e
. "$(dirname "$0")/common.sh"

say "Menyiapkan paket & direktori..."
ensure_packages

sudo mkdir -p /var/www/codef/public /var/log/codef
if [ ! -f /var/www/codef/public/index.html ]; then
  echo "<html><body><h1>CodeF Panel is running</h1></body></html>" | sudo tee /var/www/codef/public/index.html >/dev/null
fi
sudo chown -R www-data:www-data /var/www/codef

load_credentials
open_firewall

say "Core setup OK. LAN_IP=$LAN_IP, PUBLIC_IP=$PUBLIC_IP, PORT_NGINX=$PORT_NGINX, PORT_APACHE=$PORT_APACHE"
