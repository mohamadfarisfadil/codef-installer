#!/bin/bash
clear


# Auto generate struktur folder agar tidak perlu manual
mkdir -p scripts config/templates


# Unduh semua file yang dibutuhkan dari raw.githubusercontent.com
base_url="https://raw.githubusercontent.com/username/codef-installer/main"


# Unduh file scripts
wget "$base_url/scripts/setup-auto.sh" -O scripts/setup-auto.sh
wget "$base_url/scripts/setup-custom.sh" -O scripts/setup-custom.sh
wget "$base_url/scripts/core-setup.sh" -O scripts/core-setup.sh


# Unduh file konfigurasi
wget "$base_url/config/default.env" -O config/default.env
wget "$base_url/config/templates/apache.conf" -O config/templates/apache.conf
wget "$base_url/config/templates/nginx.conf" -O config/templates/nginx.conf


# Izin eksekusi
chmod +x scripts/*.sh


# Jalankan menu installer


echo "========================================="
echo " CodeF Hosting Panel Installer "
echo "========================================="
echo ""
echo "Pilih Mode Instalasi:"
echo "1. Otomatis (Recommended)"
echo "2. Kustom (Pilih fitur satu per satu)"
echo ""
read -p "Masukkan pilihan [1/2]: " mode


if [ "$mode" == "1" ]; then
bash scripts/setup-auto.sh
elif [ "$mode" == "2" ]; then
bash scripts/setup-custom.sh
else
echo "Pilihan tidak valid. Keluar."
exit 1
fi
