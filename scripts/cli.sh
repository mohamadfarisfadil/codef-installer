#!/bin/bash
set -e


BOLD='\e[1m'; NC='\e[0m'
. /etc/codef/credentials.txt


show_info(){
echo -e "${BOLD}CodeF CLI${NC}"
echo "LAN_IP : $LAN_IP"
echo "PUBLIC_IP : $PUBLIC_IP"
echo "NGINX Port : $PORT_NGINX"
echo "Apache Port: $PORT_APACHE"
}


menu(){
clear
show_info
echo "\nMenu:";
echo " 1) Start services"
echo " 2) Stop services"
echo " 3) Restart services"
echo " 4) Status"
echo " 5) Switch Mode (Public/Cloudflare) [placeholder]"
echo " 6) Tampilkan URL akses"
echo " 7) Regenerate password admin"
echo " 8) Exit"
read -rp "Pilih [1-8]: " C
case "$C" in
1) sudo systemctl start nginx || true; sudo systemctl start apache2 || true; echo "Started";;
2) sudo systemctl stop nginx || true; sudo systemctl stop apache2 || true; echo "Stopped";;
3) sudo systemctl restart nginx || true; sudo systemctl restart apache2 || true; echo "Restarted";;
4) systemctl --no-pager status nginx || true; echo; systemctl --no-pager status apache2 || true; read -rp "(enter)" _;;
5) echo "Mode switch diset di /etc/codef/mode (tbd)."; echo "Tulis: echo PUBLIC > /etc/codef/mode atau CLOUDFLARE > /etc/codef/mode"; read -rp "(enter)" _;;
6) echo "URL LAN NGINX : http://$LAN_IP:$PORT_NGINX"; echo "URL LAN APACHE : http://$LAN_IP:$PORT_APACHE"; echo "URL PUBLIC (jika ada): http://$PUBLIC_IP:$PORT_NGINX"; read -rp "(enter)" _;;
7) NEWPASS=$(openssl rand -base64 12); sudo sed -i "s/^PASSWORD=.*/PASSWORD=$NEWPASS/" /etc/codef/credentials.txt; echo "Password admin diganti: $NEWPASS"; read -rp "(enter)" _;;
8) exit 0;;
*) ;;
esac
}


if [ "$#" -gt 0 ]; then
case "$1" in
start) sudo systemctl start nginx apache2 || true ;;
stop) sudo systemctl stop nginx apache2 || true ;;
restart) sudo systemctl restart nginx apache2 || true ;;
status) systemctl --no-pager status nginx apache2 || true ;;
*) menu ;;
esac
else
while true; do menu; done
fi
