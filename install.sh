#!/bin/bash
clear


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
