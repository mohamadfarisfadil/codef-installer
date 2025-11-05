#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"

say "Install paket & siapkan direktori..."
ensure_packages

sudo mkdir -p /var/www/codef/public /var/log/codef
[ -f /var/www/codef/public/index.html ] || echo "<h1>CodeF Panel is running</h1>" | sudo tee /var/www/codef/public/index.html >/dev/null
sudo chown -R www-data:www-data /var/www/codef

load_credentials
open_firewall

say "Core OK (LAN=$LAN_IP, PUB=$PUBLIC_IP, NGINX=$PORT_NGINX, APACHE=$PORT_APACHE)"
