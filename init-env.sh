#!/usr/bin/env bash
set -euo pipefail

echo "Recreating .podman directories..."
rm -rf .podman
mkdir -p .podman/open-webui-appbackenddata
mkdir -p .podman/pgvector-varlibpostgresqldata
mkdir -p .podman/n8n-homenode.n8n
mkdir -p .podman/sim-appdata
mkdir -p .podman/realtime-appdata
mkdir -p initdb
echo "✔ .podman directories created"

gen_pass() {
  openssl rand -base64 128 | tr -d "=+/" | head -c 32
}

# Generate passwords once
POSTGRES_PASSWORD=$(gen_pass)
N8N_DB_PASSWORD=$(gen_pass)
SIM_DB_PASSWORD=$(gen_pass)
OPEN_WEBUI_DB_PASSWORD=$(gen_pass)

# -------------------------
# Generate .env
# -------------------------
cat > .env <<EOF
# Open WebUI
OPEN_WEBUI_DB=open_webui
OPEN_WEBUI_DB_USER=open_webui_user
OPEN_WEBUI_DB_PASSWORD=${OPEN_WEBUI_DB_PASSWORD}

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=postgres

# n8n
N8N_DB=n8n
N8N_DB_USER=n8n_user
N8N_DB_PASSWORD=${N8N_DB_PASSWORD}
N8N_BASIC_USER=admin
N8N_BASIC_PASSWORD=$(gen_pass)

# sim
SIM_DB=sim
SIM_DB_USER=sim_user
SIM_DB_PASSWORD=${SIM_DB_PASSWORD}
NEXT_PUBLIC_APP_URL=https://sim.skyup.online
EOF

chmod 600 .env
echo "✔ .env generated"
