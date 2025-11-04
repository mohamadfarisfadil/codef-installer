# CodeF - Panel Hosting Installer


CodeF adalah panel hosting modern dan fleksibel dengan fitur seperti multi-server (Apache + Nginx), database, email, file manager, terminal, dan lainnya.


## 🚀 Instalasi


### 1. Ambil dan jalankan installer:


```bash
wget https://raw.githubusercontent.com/mohamadfarisfadil/codef-installer/master/install.sh -O install.sh && bash install.sh
```


### 2. Pilih mode instalasi:
- Mode Otomatis: Install semua fitur standar
- Mode Custom: Pilih fitur satu per satu (Apache, Nginx, DB, dll)


### 3. Akses Panel:
- Setelah instalasi selesai, Anda akan melihat informasi:
- IP Lokal / IP Publik
- Port
- Username & Password
- Tekan `CTRL + klik` pada link di terminal untuk membuka panel di browser


## 📁 Struktur Repositori
- `install.sh` — script utama
- `scripts/setup-auto.sh` — instalasi otomatis
- `scripts/setup-custom.sh` — instalasi manual
- `assets/` — file pendukung seperti logo
- `config/` — konfigurasi default dan template server


## ❗ Catatan
- Script ini hanya berjalan di Linux (Ubuntu 24.04 direkomendasikan)
- Semua proses berjalan sepenuhnya dengan kode shell


---
