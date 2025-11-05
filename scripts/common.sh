#!/usr/bin/env bash
set -euo pipefail

say(){  echo -e "\e[1;32m[CodeF]\e[0m $*"; }
warn(){ echo -e "\e[1;33m[CodeF]\e[0m $*"; }
err(){  echo -e "\e[1;31m[CodeF]\e[0m $*"; }

ensure_packages() {
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -y >/dev/null
  sudo apt-get install -y nginx apache2 php-fpm mariadb-server ufw curl >/dev/null
}

detect_phpfpm() {
  local s
  for s in /run/php/php*-fpm.sock; do [ -S "$s" ] && { echo "unix:$s"; return; }; done
  echo "127.0.0.1:9000"
}

load_credentials() {
  sudo mkdir -p /etc/codef
  touch /etc/codef/credentials.txt

  local LAN=$(hostname -I | awk '{print $1}')
  local PUB=$(curl -s https://api.ipify.org || echo "-")

  grep -q '^LAN_IP='     /etc/codef/credentials.txt || echo "LAN_IP=$LAN"    | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PUBLIC_IP='  /etc/codef/credentials.txt || echo "PUBLIC_IP=$PUB"  | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PORT_NGINX=' /etc/codef/credentials.txt || echo "PORT_NGINX=8080" | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PORT_APACHE='/etc/codef/credentials.txt || echo "PORT_APACHE=8081"| sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^USERNAME='   /etc/codef/credentials.txt || echo "USERNAME=admin"  | sudo tee -a /etc/codef/credentials.txt >/dev/null
  grep -q '^PASSWORD='   /etc/codef/credentials.txt || echo "PASSWORD=$(openssl rand -base64 12)" | sudo tee -a /etc/codef/credentials.txt >/dev/null

  set -a; . /etc/codef/credentials.txt; set +a
  [ -z "${PORT_NGINX:-}" ] && PORT_NGINX=8080
  [ -z "${PORT_APACHE:-}" ] && PORT_APACHE=8081
}

open_firewall() {
  sudo ufw allow 80   >/dev/null 2>&1 || true
  sudo ufw allow 8080 >/dev/null 2>&1 || true
  sudo ufw allow 8081 >/dev/null 2>&1 || true
}
