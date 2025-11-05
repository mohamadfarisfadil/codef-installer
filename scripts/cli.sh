#!/usr/bin/env bash
set -e
. /etc/codef/credentials.txt

BOLD='\e[1m'; NC='\e[0m'

show(){
  clear
  echo -e "${BOLD}CodeF CLI${NC}"
  echo "LAN_IP     : ${LAN_IP}"
  echo "PUBLIC_IP  : ${PUBLIC_IP}"
  echo "NGINX Port : ${PORT_NGINX}"
  echo "Apache Port: ${PORT_APACHE}"
  echo
  echo " 1) Start services"
  echo " 2) Stop services"
  echo " 3) Restart services"
  echo " 4) Status"
  echo " 5) Tampilkan URL akses"
  echo " 6) Regenerate password admin"
  echo " 7) Exit"
  echo
  read -rp "Pilih [1-7]: " C
  case "$C" in
    1) sudo systemctl start nginx apache2 || true ;;
    2) sudo systemctl stop nginx apache2 || true ;;
    3) sudo systemctl restart nginx apache2 || true ;;
    4) systemctl --no-pager status nginx apache2 || true; read -rp "(enter) " _ ;;
    5) echo "LAN NGINX : http://${LAN_IP}:${PORT_NGINX}"; echo "LAN Apache: http://${LAN_IP}:${PORT_APACHE}"; read -rp "(enter) " _ ;;
    6) NEWPASS=$(openssl rand -base64 12); sudo sed -i "s/^PASSWORD=.*/PASSWORD=$NEWPASS/" /etc/codef/credentials.txt; echo "Password baru: $NEWPASS"; read -rp "(enter) " _ ;;
    7) exit 0 ;;
    *) ;;
  esac
}

if [ $# -gt 0 ]; then
  case "$1" in
    start|stop|restart|status) sudo systemctl "$1" nginx apache2 || true ;;
    *) ;;
  esac
else
  while true; do show; done
fi
