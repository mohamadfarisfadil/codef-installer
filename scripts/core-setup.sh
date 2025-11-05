#!/usr/bin/env bash
. "$(dirname "$0")/common.sh"

say "Install paket & siapkan direktori..."
# Bereskan APT nge-lock
sudo killall apt apt-get dpkg 2>/dev/null || true
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock
sudo dpkg --configure -a || true
sudo apt-get -f install -y || true

ensure_packages

sudo mkdir -p /var/www/codef/public /var/log/codef
[ -f /var/www/codef/public/index.html ] || echo "<h1>CodeF Panel is running</h1>" | sudo tee /var/www/codef/public/index.html >/dev/null
sudo chown -R www-data:www-data /var/www/codef

load_credentials
open_firewall

say "Core OK (LAN=$LAN_IP, PUB=$PUBLIC_IP, NGINX=$PORT_NGINX, APACHE=$PORT_APACHE)"
