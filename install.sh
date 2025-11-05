#!/usr/bin/env bash
set -e
clear

# === Konfigurasi sumber unduh (bisa override pakai BASE_URL=... bash install.sh) ===
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/mohamadfarisfadil/codef-installer/main}"

say(){ echo -e "\e[1;32m[CodeF]\e[0m $*"; }
warn(){ echo -e "\e[1;33m[CodeF]\e[0m $*"; }
err(){ echo -e "\e[1;31m[CodeF]\e[0m $*"; }

mkdir -p scripts config/templates assets

say "Mengunduh skrip & template..."
wget -q "$BASE_URL/scripts/common.sh"        -O scripts/common.sh
wget -q "$BASE_URL/scripts/core-setup.sh"    -O scripts/core-setup.sh
wget -q "$BASE_URL/scripts/setup-auto.sh"    -O scripts/setup-auto.sh
wget -q "$BASE_URL/scripts/setup-custom.sh"  -O scripts/setup-custom.sh
wget -q "$BASE_URL/scripts/cli.sh"           -O scripts/cli.sh
wget -q "$BASE_URL/config/default.env"       -O config/default.env
wget -q "$BASE_URL/config/templates/nginx.conf"  -O config/templates/nginx.conf
wget -q "$BASE_URL/config/templates/apache.conf" -O config/templates/apache.conf

chmod +x scripts/*.sh

# Pasang CLI
sudo cp scripts/cli.sh /usr/local/bin/codef
sudo chmod +x /usr/local/bin/codef

# Core setup (install paket, dir, kredensial, firewall)
sudo bash scripts/core-setup.sh

clear
say "========================================="
say " CodeF Hosting Panel Installer "
say "========================================="
echo
echo "Pilih Mode Instalasi:"
echo " 1) Otomatis (disarankan)"
echo " 2) Kustom (pilih fitur)"
echo
read -rp "Masukkan pilihan [1/2]: " MODE

case "$MODE" in
  1) bash scripts/setup-auto.sh ;;
  2) bash scripts/setup-custom.sh ;;
  *) err "Pilihan tidak valid"; exit 1 ;;
esac

say "Selesai instalasi. Gunakan perintah: \e[1mcodef\e[0m untuk membuka menu CLI."
