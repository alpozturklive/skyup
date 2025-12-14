#!/usr/bin/env bash
set -e

gen_pass() {
  openssl rand -base64 32
}

cat > .env <<EOF
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(gen_pass)
POSTGRES_DB=main

# SimStudio
SIM_DB=sim
SIM_DB_USER=sim_user
SIM_DB_PASSWORD=$(gen_pass)

# n8n
N8N_DB=n8n
N8N_DB_USER=n8n_user
N8N_DB_PASSWORD=$(gen_pass)
N8N_BASIC_USER=admin
N8N_BASIC_PASSWORD=$(gen_pass)

# MongoDB
MONGO_ROOT_USER=mongo
MONGO_ROOT_PASSWORD=$(gen_pass)
MONGO_DB=librechat

# LibreChat admin
LIBRECHAT_ADMIN_EMAIL=admin@local
LIBRECHAT_ADMIN_PASSWORD=$(gen_pass)
EOF

chmod 600 .env
echo "✔ .env generated"
