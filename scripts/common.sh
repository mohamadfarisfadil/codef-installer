#!/usr/bin/env bash
set -e

say(){ echo -e "\e[1;32m[CodeF]\e[0m $*"; }
warn(){ echo -e "\e[1;33m[CodeF]\e[0m $*"; }
err(){ echo -e "\e[1;31m[CodeF]\e[0m $*"; }

ensure_packages() {
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -y >/dev/null
  sudo apt-get install -y nginx apache2 php-fpm mariadb-server ufw curl >/dev/null
}

detect_phpfpm_sock() {
  # ambil socket php-fpm yang ada
  local sock
  sock=$(ls /run/php/php*-fpm.sock 2>/dev/null | head -n1)
  echo "${sock:-/run/php/php8.2-fpm.sock}"
}

load_credentials() {
  sudo mkdir -p /etc/codef
  touch /etc/codef/credentials.txt

  local LAN_IP PUBLIC_IP
  LAN_IP=$(hostname -I | awk '{print $1}')
  PUBLIC_IP=$(curl -s https://api.ipify.org || echo "-")

  # tulis jika kunci belum ada
  grep -q '^LAN_IP=' /etc/codef/credentials.txt     || echo "LAN_IP=$LAN_IP"           | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PUBLIC_IP=' /etc/codef/credentials.txt  || echo "PUBLIC_IP=$PUBLIC_IP"     | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PORT_NGINX=' /etc/codef/credentials.txt || echo "PORT_NGINX=8080"          | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PORT_APACHE=' /etc/codef/credentials.txt|| echo "PORT_APACHE=8081"         | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^USERNAME=' /etc/codef/credentials.txt   || echo "USERNAME=admin"           | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PASSWORD=' /etc/codef/credentials.txt   || echo "PASSWORD=$(openssl rand -base64 12)" | sudo tee -a /etc/codef/credentials.txt >/dev/null

  # export
  set -a
  . /etc/codef/credentials.txt
  set +a

  # fallback kalau masih kosong
  [ -z "${PORT_NGINX:-}" ] && PORT_NGINX=8080
  [ -z "${PORT_APACHE:-}" ] && PORT_APACHE=8081
}

open_firewall() {
  sudo ufw allow 22  >/dev/null 2>&1 || true
  sudo ufw allow 80  >/dev/null 2>&1 || true
  sudo ufw allow 8080 >/dev/null 2>&1 || true
  sudo ufw allow 8081 >/dev/null 2>&1 || true
}
