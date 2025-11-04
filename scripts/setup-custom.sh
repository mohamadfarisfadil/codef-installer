#!/bin/bash
echo "4. phpMyAdmin"
echo "5. File Manager"
echo "6. Terminal"
echo "7. Selesai"
declare -a fitur


while true; do
read -p "Pilih nomor fitur (atau 7 untuk selesai): " pilih
if [ "$pilih" == "7" ]; then
break
fi
fitur+=("$pilih")
done


echo "\nFitur yang akan diinstal: ${fitur[@]}"
sleep 1


for f in "${fitur[@]}"; do
case $f in
1) echo "Menginstal Apache..." ;;
2) echo "Menginstal Nginx..." ;;
3) echo "Menginstal MariaDB..." ;;
4) echo "Menginstal phpMyAdmin..." ;;
5) echo "Menginstal File Manager..." ;;
6) echo "Menginstal Terminal..." ;;
esac
sleep 1
done


LOCAL_IP="127.0.0.1"
PUBLIC_IP=$(curl -s https://api.ipify.org)
USERNAME="admin"
PASSWORD="$(openssl rand -base64 12)"
PORT="8080"
echo "\n--- Informasi Panel ---"
echo "Local: http://$LOCAL_IP:$PORT"
echo "Public: http://$PUBLIC_IP:$PORT"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "\nTekan CTRL + klik pada link untuk membuka di browser."


cat <<EOF > /etc/codef/credentials.txt
IP Lokal: $LOCAL_IP
IP Publik: $PUBLIC_IP
Username: $USERNAME
Password: $PASSWORD
Port: $PORT
EOF
