# CodeF - Panel Hosting Installer


CodeF adalah panel hosting modern dan fleksibel dengan fitur seperti multi-server (Apache + Nginx), database, email, file manager, terminal, dan lainnya.


## 🚀 Langkah Instalasi (Manual via Raw GitHub)


### 1. Buat Struktur Folder
```bash
mkdir -p codef-installer/scripts
mkdir -p codef-installer/config/templates
cd codef-installer
```


### 2. Unduh Semua File Kode Mentah via Raw GitHub
Gantilah `username` dan `branch` sesuai repository Anda (biasanya `main` atau `master`).


```bash
# File utama
wget https://raw.githubusercontent.com/username/codef-installer/main/install.sh -O install.sh


# Scripts
wget https://raw.githubusercontent.com/username/codef-installer/main/scripts/setup-auto.sh -O scripts/setup-auto.sh
wget https://raw.githubusercontent.com/username/codef-installer/main/scripts/setup-custom.sh -O scripts/setup-custom.sh
wget https://raw.githubusercontent.com/username/codef-installer/main/scripts/core-setup.sh -O scripts/core-setup.sh


# Config
wget https://raw.githubusercontent.com/username/codef-installer/main/config/default.env -O config/default.env
wget https://raw.githubusercontent.com/username/codef-installer/main/config/templates/apache.conf -O config/templates/apache.conf
wget https://raw.githubusercontent.com/username/codef-installer/main/config/templates/nginx.conf -O config/templates/nginx.conf


# Izin eksekusi
chmod +x install.sh scripts/*.sh
```


### 3. Jalankan Installer
```bash
bash install.sh
```


### 4. Ikuti Instruksi
- Pilih mode instalasi (otomatis atau kustom)
- Setelah instalasi selesai, Anda akan melihat informasi:
- IP Lokal / IP Publik
- Port
- Username & Password
- Tekan `CTRL + klik` pada link yang muncul di terminal untuk membuka panel di browser.


---


## 📁 Struktur Repositori
- `install.sh` — script utama
- `scripts/setup-auto.sh` — instalasi otomatis
- `scripts/setup-custom.sh` — instalasi manual
- `scripts/core-setup.sh` — setup dasar environment
- `config/` — konfigurasi default dan template web server


## ❗ Catatan
- Script ini hanya berjalan di Linux (Ubuntu 24.04 direkomendasikan)
- Tidak menggunakan `git clone`, `.zip`, atau `.doc`
- Semua diambil dalam bentuk **kode mentah via raw.githubusercontent.com**


---
