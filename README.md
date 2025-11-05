# CodeF - Panel Hosting Installer


## Instalasi 1-Baris (Otomatis)
```bash
wget https://raw.githubusercontent.com/mohamadfarisfadil/codef-installer/main/install.sh -O install.sh && bash install.sh
```
- Script akan otomatis membuat folder, mengunduh file, set permission, memasang service, membuka port (ufw), dan bind ke 0.0.0.0.
- Setelah selesai, jalankan `codef` untuk membuka menu CLI (1/2/3/4/...).


## Akses
- LAN: `http://<IP-LAN>:8080` (NGINX), `http://<IP-LAN>:8081` (Apache)
- Localhost: `http://127.0.0.1:8080`


## CLI
- Buka menu: `codef`
- Perintah cepat: `codef start|stop|restart|status`
