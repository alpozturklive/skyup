#!/usr/bin/env bash
set -euo pipefail

echo "Resetting .podman directories (preserving open-webui)..."
rm -rf .podman/pgvector-varlibpostgresqldata
rm -rf .podman/n8n-homenode.n8n

mkdir -p .podman/open-webui-appbackenddata
mkdir -p .podman/pgvector-varlibpostgresqldata
mkdir -p .podman/n8n-homenode.n8n
mkdir -p initdb
echo "✔ .podman directories reset"

gen_pass() {
  openssl rand -base64 128 | tr -d "=+/" | head -c 32
}

# Load existing .env variables if the file exists
if [ -f .env ]; then
  source .env
fi

# Generate passwords if not already set
: "${POSTGRES_PASSWORD:=$(gen_pass)}"
: "${N8N_DB_PASSWORD:=$(gen_pass)}"
: "${OPEN_WEBUI_DB_PASSWORD:=$(gen_pass)}"
: "${N8N_BASIC_PASSWORD:=$(gen_pass)}"
: "${MEMORY_DB_PASSWORD:=$(gen_pass)}"

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
N8N_BASIC_PASSWORD=${N8N_BASIC_PASSWORD}

# Memory database for n8n workflows
MEMORY_DB=memory
MEMORY_DB_USER=memory_user
MEMORY_DB_PASSWORD=${MEMORY_DB_PASSWORD}
EOF

chmod 600 .env
echo "✔ .env generated"
