#!/bin/bash
set -e


say() { echo -e "\e[1;32m[Core]\e[0m $1"; }
warn() { echo -e "\e[1;33m[Core]\e[0m $1"; }


# Update & paket minimal
export DEBIAN_FRONTEND=noninteractive
say "Update paket..."
sudo apt-get update -y >/dev/null
say "Memasang paket wajib (nginx, apache2, php-fpm, mariadb, ufw, curl)..."
sudo apt-get install -y nginx apache2 php-fpm mariadb-server ufw curl >/dev/null


# Direktori CodeF
sudo mkdir -p /var/www/codef/public
sudo mkdir -p /etc/codef
sudo mkdir -p /var/log/codef


# Index sederhana
if [ ! -f /var/www/codef/public/index.html ]; then
echo "<html><head><title>CodeF</title></head><body><h1>CodeF Panel is running</h1></body></html>" | sudo tee /var/www/codef/public/index.html >/dev/null
fi
sudo chown -R www-data:www-data /var/www/codef


# Deteksi IP
LAN_IP=$(hostname -I | awk '{print $1}')
PUB_IP=$(curl -s https://api.ipify.org || echo "-")
PORT_NGINX=8080
PORT_APACHE=8081


# Simpan kredensial & info dasar
if [ ! -f /etc/codef/credentials.txt ]; then
USERNAME=admin
PASSWORD=$(openssl rand -base64 12)
{
echo "LAN_IP=$LAN_IP"
echo "PUBLIC_IP=$PUB_IP"
echo "PORT_NGINX=$PORT_NGINX"
echo "PORT_APACHE=$PORT_APACHE"
echo "USERNAME=$USERNAME"
echo "PASSWORD=$PASSWORD"
} | sudo tee /etc/codef/credentials.txt >/dev/null
fi


# Firewall (izinkan 22, 80, 8080, 8081)
if command -v ufw >/dev/null 2>&1; then
sudo ufw allow 22 >/dev/null || true
sudo ufw allow 80 >/dev/null || true
sudo ufw allow 8080 >/dev/null || true
sudo ufw allow 8081 >/dev/null || true
fi


say "Core setup selesai. LAN_IP=$LAN_IP, PUBLIC_IP=$PUB_IP"
