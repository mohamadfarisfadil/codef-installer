# CodeF Installer (Auto + CLI)

## Install 1 Baris
Ganti USER & BRANCH sesuai GitHub kamu:

```bash
USER="YOUR_GH_USERNAME"; BRANCH="main"
RAW="https://raw.githubusercontent.com/$USER/codef-installer/$BRANCH"
wget "$RAW/install.sh" -O install.sh && BASE_URL="$RAW" bash install.sh
