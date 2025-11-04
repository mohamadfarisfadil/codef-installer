#!/bin/bash


echo "\n[Auto Installer] Menyiapkan semua fitur default..."
# Simulasi penginstalan default
sleep 1
echo "Menginstal Apache + Nginx (multi-server)..."
sleep 1
echo "Menginstal Database (MariaDB)..."
sleep 1
echo "Menginstal phpMyAdmin, File Manager, Terminal..."
sleep 1
echo "Selesai."


# Generate informasi akses
echo "\n--- Informasi Panel ---"
LOCAL_IP="127.0.0.1"
PUBLIC_IP=$(curl -s https://api.ipify.org)
USERNAME="admin"
PASSWORD="$(openssl rand -base64 12)"
PORT="8080"
echo "Local: http://$LOCAL_IP:$PORT"
echo "Public: http://$PUBLIC_IP:$PORT"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "\nTekan CTRL + klik pada link untuk membuka di browser."


mkdir -p /etc/codef
cat <<EOF > /etc/codef/credentials.txt
IP Lokal: $LOCAL_IP
IP Publik: $PUBLIC_IP
Username: $USERNAME
Password: $PASSWORD
Port: $PORT
EOF
