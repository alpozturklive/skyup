#!/usr/bin/env bash
set -euo pipefail

gen_pass() {
  openssl rand -base64 128 | tr -d "=+/" | head -c 32
}

mkdir -p initdb

# Generate passwords once
POSTGRES_PASSWORD=$(gen_pass)
N8N_DB_PASSWORD=$(gen_pass)
SIM_DB_PASSWORD=$(gen_pass)

# -------------------------
# Generate .env
# -------------------------
cat > .env <<EOF
# LibreChat
MONGO_ROOT_PASSWORD=$(gen_pass)
JWT_SECRET=$(gen_pass)
JWT_REFRESH_SECRET=$(gen_pass)
SESSION_SECRET=$(gen_pass)
CREDS_KEY=$(openssl rand -hex 32)
CREDS_IV=$(openssl rand -hex 16)
LIBRECHAT_ADMIN_EMAIL=admin@skyup.online
LIBRECHAT_ADMIN_PASSWORD=$(gen_pass)
ALLOW_REGISTRATION=false
ALLOW_SOCIAL_LOGIN=false
ALLOW_EMAIL_LOGIN=true

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
