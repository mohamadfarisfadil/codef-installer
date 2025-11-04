#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# CodeF – Lightweight Hosting Panel (MVP)
# Single-file installer. Tested on Ubuntu 20.04/22.04/24.04.
# Features:
# - Core services: reverse proxy (nginx-proxy), Portainer, File Browser, Adminer, Web Terminal (gotty)
# - Quick Install Apps via `codef` CLI: wordpress, laravel, ci4, php, html
# - Sites are isolated with per-site docker-compose on a shared docker network
# - Default access ports:
#     Proxy (HTTP): 2080 (now with a landing page + header logo)
#     Portainer:    9000
#     FileBrowser:  8080
#     Web Terminal: 8081
#     Adminer:      8082
# - Works well with Cloudflare Tunnel or local-only setups
# - Branding: configurable PNG logo shown in landing header (change via `codef brand logo ...`)
# ============================================================

# -------------------------------
# Constants & Defaults
# -------------------------------
CODEF_DIR="/opt/codef"
CODEF_BIN="/usr/local/bin/codef"
CODEF_NET="codef-net"
PROXY_NAME="codef-proxy"
HOME_NAME="codef-home"
PROXY_HTTP_PORT="2080"
PORTAINER_PORT="9000"
FILEBROWSER_PORT="8080"
GOTTY_PORT="8081"
ADMINER_PORT="8082"
DEFAULT_HOST="codef.home"   # default virtual host for the landing page (used by nginx-proxy)

# Branding paths
CODEF_BRAND_DIR="$CODEF_DIR/branding"
CODEF_BRAND_LOGO="$CODEF_BRAND_DIR/logo.png"
CODEF_HOME_DIR="$CODEF_DIR/home"

# -------------------------------
# Helpers
# -------------------------------
msg() { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[!]\033[0m %s\n" "$*" 1>&2; }
req() { printf "\033[1;34m[*]\033[0m %s\n" "$*"; }

need_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    err "Please run as root (use sudo)."; exit 1;
  fi
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Detect docker compose command variant
compose_cmd() {
  if command_exists docker && docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif command_exists docker-compose; then
    echo "docker-compose"
  else
    echo "" # not installed
  fi
}

# -------------------------------
# Install prerequisites
# -------------------------------
install_deps() {
  req "Installing system dependencies..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y \
    ca-certificates curl gnupg lsb-release git tar
}

install_docker() {
  if command_exists docker; then
    msg "Docker already installed."
  else
    req "Installing Docker Engine..."
    install_deps
    # Docker official repo
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
    msg "Docker installed."
  fi

  if [ -z "$(compose_cmd)" ]; then
    err "Docker Compose not detected. Ensure docker-compose-plugin is installed."; exit 1;
  fi
}

# -------------------------------
# Core layout & branding
# -------------------------------
bootstrap_layout() {
  req "Preparing directories..."
  mkdir -p "$CODEF_DIR"/{core,sites,data,filebrowser}
  mkdir -p "$CODEF_BRAND_DIR" "$CODEF_HOME_DIR"
}

ensure_default_logo() {
  if [ ! -f "$CODEF_BRAND_LOGO" ]; then
    req "Creating default logo (PNG)..."
    # 1x1 transparent PNG placeholder (replace via CLI later)
    base64 -d > "$CODEF_BRAND_LOGO" <<'B64PNG'
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=
B64PNG
  fi
}

write_home_page() {
  req "Writing landing page..."
  cat >"$CODEF_HOME_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>CodeF Panel</title>
  <style>
    :root { --bg:#0b1220; --fg:#e6edf3; --muted:#9da7b3; --card:#121a2a; }
    * { box-sizing:border-box; }
    body { margin:0; font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji"; background:var(--bg); color:var(--fg); }
    header { display:flex; align-items:center; gap:16px; padding:20px; border-bottom:1px solid #223; background:linear-gradient(180deg,#0f172a,#0b1220); position:sticky; top:0; }
    header img { height:40px; width:auto; image-rendering:auto; }
    header h1 { margin:0; font-size:20px; letter-spacing:.3px; font-weight:600; }
    main { max-width:960px; margin:30px auto; padding:0 16px; }
    .grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap:16px; }
    .card { background:var(--card); padding:16px; border-radius:16px; border:1px solid #1e2636; box-shadow:0 1px 0 rgba(255,255,255,.04) inset; }
    .card h3 { margin:0 0 8px 0; font-size:16px; }
    .muted { color:var(--muted); font-size:13px; }
    a.btn { display:inline-block; padding:10px 12px; border-radius:12px; border:1px solid #2a3752; text-decoration:none; color:var(--fg); margin-top:10px; }
    footer { text-align:center; color:#7f8aa3; font-size:12px; padding:30px 0 50px; }
    code { background:#0e1626; padding:2px 6px; border-radius:6px; border:1px solid #1f2a41; }
  </style>
</head>
<body>
  <header>
    <img src="/branding/logo.png" alt="CodeF" onerror="this.style.display='none'">
    <h1>CodeF Panel</h1>
  </header>
  <main>
    <p class="muted">Welcome! This landing routes to core tools running on this host. Links below auto-detect the hostname.</p>
    <div class="grid">
      <div class="card"><h3>Proxy (this page)</h3><p class="muted">HTTP on port <code>2080</code>.</p><a class="btn" id="lnk-proxy" href="#">Open</a></div>
      <div class="card"><h3>Portainer</h3><p class="muted">Docker UI at <code>9000</code>.</p><a class="btn" id="lnk-portainer" href="#">Open</a></div>
      <div class="card"><h3>File Browser</h3><p class="muted">File manager at <code>8080</code>. Default <code>admin/admin</code>.</p><a class="btn" id="lnk-fb" href="#">Open</a></div>
      <div class="card"><h3>Web Terminal</h3><p class="muted">gotty at <code>8081</code>.</p><a class="btn" id="lnk-term" href="#">Open</a></div>
      <div class="card"><h3>Adminer</h3><p class="muted">DB UI at <code>8082</code>.</p><a class="btn" id="lnk-adminer" href="#">Open</a></div>
    </div>
    <p class="muted" style="margin-top:22px">Change the header logo with <code>codef brand logo set &lt;path-or-url&gt;</code>. The file is stored at <code>/opt/codef/branding/logo.png</code>.</p>
  </main>
  <footer>© <span id="year"></span> CodeF</footer>
  <script>
    const host = location.hostname; const proto = location.protocol;
    const set = (id, port, path='') => { const el = document.getElementById(id); if (el) el.href = `${proto}//${host}:${port}${path}`; };
    set('lnk-proxy', 2080, '/');
    set('lnk-portainer', 9000);
    set('lnk-fb', 8080);
    set('lnk-term', 8081);
    set('lnk-adminer', 8082);
    document.getElementById('year').textContent = new Date().getFullYear();
  </script>
</body>
</html>
HTML
}

create_network() {
  if ! docker network inspect "$CODEF_NET" >/dev/null 2>&1; then
    req "Creating docker network: $CODEF_NET"
    docker network create "$CODEF_NET"
  else
    msg "Network $CODEF_NET exists."
  fi
}

# -------------------------------
# Core stack: reverse proxy + utilities + landing page
# -------------------------------
start_core_stack() {
  req "Starting core services (proxy, landing, portainer, filebrowser, adminer, gotty)..."

  # Reverse proxy (nginx-proxy) with DEFAULT_HOST for landing
  if ! docker ps --format '{{.Names}}' | grep -q "^${PROXY_NAME}$"; then
    docker run -d \
      --name "$PROXY_NAME" \
      --restart unless-stopped \
      -p ${PROXY_HTTP_PORT}:80 \
      -e DEFAULT_HOST="$DEFAULT_HOST" \
      -v /var/run/docker.sock:/tmp/docker.sock:ro \
      --network "$CODEF_NET" \
      nginxproxy/nginx-proxy:alpine
  else
    msg "Proxy already running."
  fi

  # Landing page (default host)
  if ! docker ps --format '{{.Names}}' | grep -q "^${HOME_NAME}$"; then
    docker run -d \
      --name "$HOME_NAME" \
      --restart unless-stopped \
      -e VIRTUAL_HOST="$DEFAULT_HOST" \
      -v "$CODEF_HOME_DIR":/usr/share/nginx/html:ro \
      -v "$CODEF_BRAND_DIR":/usr/share/nginx/html/branding:ro \
      --network "$CODEF_NET" \
      nginx:alpine
  fi

  # Portainer (Docker UI)
  if ! docker ps --format '{{.Names}}' | grep -q '^codef-portainer$'; then
    docker volume create portainer_data >/dev/null
    docker run -d \
      --name codef-portainer \
      --restart unless-stopped \
      -p ${PORTAINER_PORT}:9000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      --network "$CODEF_NET" \
      portainer/portainer-ce:latest
  fi

  # File Browser
  if ! docker ps --format '{{.Names}}' | grep -q '^codef-filebrowser$'; then
    docker run -d \
      --name codef-filebrowser \
      --restart unless-stopped \
      -p ${FILEBROWSER_PORT}:80 \
      -v "$CODEF_DIR/data":/srv \
      --network "$CODEF_NET" \
      filebrowser/filebrowser:latest
  fi

  # Adminer (DB UI)
  if ! docker ps --format '{{.Names}}' | grep -q '^codef-adminer$'; then
    docker run -d \
      --name codef-adminer \
      --restart unless-stopped \
      -p ${ADMINER_PORT}:8080 \
      --network "$CODEF_NET" \
      adminer:latest
  fi

  # gotty (Web terminal)
  if ! docker ps --format '{{.Names}}' | grep -q '^codef-gotty$'; then
    docker run -d \
      --name codef-gotty \
      --restart unless-stopped \
      -p ${GOTTY_PORT}:8080 \
      -v /:/rootfs \
      -w /rootfs \
      --privileged \
      --network "$CODEF_NET" \
      sspreitzer/gotty:latest bash
  fi

  msg "Core services are up:"
  echo "  - Panel Landing:   http://<server-ip>:${PROXY_HTTP_PORT}/  (shows header + logo)"
  echo "  - Portainer:       http://<server-ip>:${PORTAINER_PORT}"
  echo "  - File Browser:    http://<server-ip>:${FILEBROWSER_PORT} (default admin/admin)"
  echo "  - Web Terminal:    http://<server-ip>:${GOTTY_PORT}"
  echo "  - Adminer:         http://<server-ip>:${ADMINER_PORT}"
}

# -------------------------------
# codef CLI generator (with branding commands)
# -------------------------------
install_codef_cli() {
  req "Installing codef CLI -> $CODEF_BIN"
  cat > "$CODEF_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
CODEF_DIR="/opt/codef"
CODEF_NET="codef-net"
PROXY_HTTP_PORT="2080"
COMPOSE="$(if docker compose version >/dev/null 2>&1; then echo 'docker compose'; else echo 'docker-compose'; fi)"
CODEF_BRAND_DIR="$CODEF_DIR/branding"
CODEF_BRAND_LOGO="$CODEF_BRAND_DIR/logo.png"

usage() {
  cat <<USG
CodeF CLI – manage sites & branding

Usage:
  codef quick <type> <domain>
    Types: wordpress | laravel | ci4 | php | html

  codef list
  codef start <domain>
  codef stop <domain>
  codef remove <domain>
  codef status <domain>
  codef logs <domain>

Branding:
  codef brand logo set <path-or-url>
  codef brand logo reset
  codef brand logo show

Examples:
  codef quick wordpress blog.local
  codef brand logo set /root/mylogo.png
  codef brand logo set https://example.com/logo.png
USG
}

ensure_net() { docker network inspect "$CODEF_NET" >/dev/null 2>&1 || docker network create "$CODEF_NET" >/dev/null; }
ensure_dir() { mkdir -p "$1"; }
site_dir() { echo "$CODEF_DIR/sites/$1"; }
compose_file() { echo "$(site_dir "$1")/docker-compose.yml"; }
randpw() { tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo; }

# ---------- Quick apps ----------
create_wp() {
  local domain="$1"; local dir="$(site_dir "$domain")"; ensure_dir "$dir"
  local db="wp$(echo "$domain" | tr -cd 'a-z0-9' | head -c 8)"
  local db_user="wpuser"; local db_pass="$(randpw)"
  cat >"$dir/.env" <<EENV
DOMAIN=$domain
DB_NAME=$db
DB_USER=$db_user
DB_PASSWORD=$db_pass
EENV
  cat >"$dir/docker-compose.yml" <<'YAML'
services:
  db:
    image: mariadb:11
    restart: unless-stopped
    environment:
      MARIADB_DATABASE: ${DB_NAME}
      MARIADB_USER: ${DB_USER}
      MARIADB_PASSWORD: ${DB_PASSWORD}
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks: [codef-net]

  wordpress:
    image: wordpress:latest
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
      VIRTUAL_HOST: ${DOMAIN}
    depends_on: [db]
    volumes:
      - wp_data:/var/www/html
    networks: [codef-net]

volumes:
  db_data:
  wp_data:

networks:
  codef-net:
    external: true
YAML
  (cd "$dir" && $COMPOSE --env-file .env up -d)
  echo "WordPress deployed at http://$domain (via proxy on port $PROXY_HTTP_PORT)."
}

create_php() {
  local domain="$1"; local dir="$(site_dir "$domain")"; ensure_dir "$dir"
  mkdir -p "$dir/www"
  cat >"$dir/www/index.php" <<'PHP'
<?php phpinfo();
PHP
  cat >"$dir/docker-compose.yml" <<'YAML'
services:
  app:
    image: php:8.2-apache
    restart: unless-stopped
    environment:
      VIRTUAL_HOST: ${DOMAIN}
    volumes:
      - ./www:/var/www/html
    networks: [codef-net]

networks:
  codef-net:
    external: true
YAML
  echo "DOMAIN=$domain" >"$dir/.env"
  (cd "$dir" && $COMPOSE --env-file .env up -d)
  echo "PHP site deployed at http://$domain (via proxy on port $PROXY_HTTP_PORT)."
}

create_html() {
  local domain="$1"; local dir="$(site_dir "$domain")"; ensure_dir "$dir"
  mkdir -p "$dir/www"
  cat >"$dir/www/index.html" <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>CodeF Static Site</title></head>
<body><h1>It works!</h1><p>Served by CodeF.</p></body></html>
HTML
  cat >"$dir/docker-compose.yml" <<'YAML'
services:
  web:
    image: nginx:alpine
    restart: unless-stopped
    environment:
      VIRTUAL_HOST: ${DOMAIN}
    volumes:
      - ./www:/usr/share/nginx/html:ro
    networks: [codef-net]

networks:
  codef-net:
    external: true
YAML
  echo "DOMAIN=$domain" >"$dir/.env"
  (cd "$dir" && $COMPOSE --env-file .env up -d)
  echo "Static site deployed at http://$domain (via proxy on port $PROXY_HTTP_PORT)."
}

create_laravel_like() {
  local domain="$1"; local framework="$2"; local pkg="$3"; local dir="$(site_dir "$domain")"; ensure_dir "$dir"
  mkdir -p "$dir/app"
  docker run --rm -v "$dir/app":/app -w /app composer:2 bash -lc "composer create-project $pkg app && mv app/* . && rmdir app"
  cat >"$dir/docker-compose.yml" <<'YAML'
services:
  app:
    image: webdevops/php-apache-dev:8.2
    restart: unless-stopped
    environment:
      VIRTUAL_HOST: ${DOMAIN}
      WEB_DOCUMENT_ROOT: /app/public
    working_dir: /app
    volumes:
      - ./app:/app
    networks: [codef-net]

networks:
  codef-net:
    external: true
YAML
  echo "DOMAIN=$domain" >"$dir/.env"
  (cd "$dir" && $COMPOSE --env-file .env up -d)
  echo "$framework app deployed at http://$domain (via proxy on port $PROXY_HTTP_PORT)."
}

create_laravel() { create_laravel_like "$1" "Laravel" "laravel/laravel"; }
create_ci4()    { create_laravel_like "$1" "CodeIgniter 4" "codeigniter4/appstarter"; }

list_sites() { ls -1 "$CODEF_DIR/sites" 2>/dev/null || true; }
start_site() { (cd "$(site_dir "$1")" && $COMPOSE --env-file .env up -d); }
stop_site() { (cd "$(site_dir "$1")" && $COMPOSE --env-file .env down); }
rm_site() { (cd "$(site_dir "$1")" && $COMPOSE --env-file .env down -v); rm -rf "$(site_dir "$1")"; }
status_site(){ (cd "$(site_dir "$1")" && $COMPOSE ps); }
logs_site() { (cd "$(site_dir "$1")" && $COMPOSE logs -f); }

# ---------- Branding ----------
brand_logo_set() {
  local src="${1:-}"; [ -z "$src" ] && { echo "Usage: codef brand logo set <path-or-url>"; exit 1; }
  mkdir -p "$CODEF_BRAND_DIR"
  if echo "$src" | grep -Eqi '^https?://'; then
    curl -fsSL "$src" -o "$CODEF_BRAND_LOGO"
  else
    cp "$src" "$CODEF_BRAND_LOGO"
  fi
  echo "Logo updated -> $CODEF_BRAND_LOGO"
}

brand_logo_reset() {
  mkdir -p "$CODEF_BRAND_DIR"
  base64 -d > "$CODEF_BRAND_LOGO" <<'B64PNG'
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=
B64PNG
  echo "Logo reset to default -> $CODEF_BRAND_LOGO"
}

brand_logo_show() { echo "$CODEF_BRAND_LOGO"; }

main() {
  ensure_net
  local cmd="${1:-}"; case "$cmd" in
    quick)
      local type="${2:-}"; local domain="${3:-}"; [ -z "$type" -o -z "$domain" ] && usage && exit 1
      case "$type" in
        wordpress) create_wp "$domain" ;;
        laravel)   create_laravel "$domain" ;;
        ci4)       create_ci4 "$domain" ;;
        php)       create_php "$domain" ;;
        html)      create_html "$domain" ;;
        *) usage; exit 1;;
      esac
      ;;
    list)   list_sites ;;
    start)  start_site  "${2:-}" ;;
    stop)   stop_site   "${2:-}" ;;
    remove) rm_site     "${2:-}" ;;
    status) status_site "${2:-}" ;;
    logs)   logs_site   "${2:-}" ;;

    brand)
      case "${2:-}" in
        logo)
          case "${3:-}" in
            set)   brand_logo_set "${4:-}" ;;
            reset) brand_logo_reset ;;
            show)  brand_logo_show ;;
            *) echo "Usage: codef brand logo {set <path-or-url>|reset|show}"; exit 1;;
          esac ;;
        *) echo "Usage: codef brand logo {set|reset|show}"; exit 1;;
      esac ;;

    *) usage ;;
  esac
}

main "$@"
EOF
  chmod +x "$CODEF_BIN"
  msg "codef CLI installed. Try: codef brand logo show"
}

# -------------------------------
# Main
# -------------------------------
need_root
install_docker
bootstrap_layout
ensure_default_logo
write_home_page
create_network
start_core_stack
install_codef_cli

msg "Done!"
cat <<EOM

Next steps:
  1) Panel Landing:      http://<server-ip>:${PROXY_HTTP_PORT}/    (shows header with logo)
  2) Portainer:          http://<server-ip>:${PORTAINER_PORT}
  3) File Manager:       http://<server-ip>:${FILEBROWSER_PORT} (default admin/admin)
  4) Web Terminal:       http://<server-ip>:${GOTTY_PORT}
  5) Adminer (DB UI):    http://<server-ip>:${ADMINER_PORT}

Branding:
  - Set logo from local file:  codef brand logo set /root/mylogo.png
  - Set logo from URL:         codef brand logo set https://example.com/logo.png
  - Reset to default:          codef brand logo reset
  - Logo path:                 $CODEF_BRAND_LOGO

If using Cloudflare Tunnel, expose ports ${PROXY_HTTP_PORT}, ${PORTAINER_PORT}, ${FILEBROWSER_PORT}, ${GOTTY_PORT}, ${ADMINER_PORT} as needed.
EOM
