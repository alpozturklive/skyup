#!/usr/bin/env bash
set -e

gen_pass() {
  openssl rand -base64 48 | tr -d "=+/" | head -c 32
}

ENV_FILE=".env"
SQL_FILE="initdb/01-postgres-init.sql"

#################################
# Generate .env
#################################

cat > "$ENV_FILE" <<EOF

#librechat
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=$(gen_pass)
MONGO_DB=LibreChat
JWT_SECRET=$(gen_pass)
JWT_REFRESH_SECRET=$(gen_pass)
SESSION_SECRET=$(gen_pass)
CREDS_KEY=$(gen_pass)
CREDS_IV=$(gen_pass|head -c 16)
LIBRECHAT_ADMIN_EMAIL=admin@skyup.online
LIBRECHAT_ADMIN_PASSWORD=$(gen_pass)
ALLOW_REGISTRATION=false
ALLOW_SOCIAL_LOGIN=false
ALLOW_EMAIL_LOGIN=true
APP_TITLE=LibreChat
DOMAIN_CLIENT=http://localhost:3080
DOMAIN_SERVER=http://localhost:3080

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(gen_pass)
POSTGRES_DB=main

# n8n
N8N_DB=n8n
N8N_DB_USER=n8n_user
N8N_DB_PASSWORD=$(gen_pass)
N8N_BASIC_USER=admin
N8N_BASIC_PASSWORD=$(gen_pass)

# sim
SIM_DB=sim
SIM_DB_USER=sim_user
SIM_DB_PASSWORD=$(gen_pass)
NEXT_PUBLIC_APP_URL=https://sim.skyup.online

EOF

chmod 600 "$ENV_FILE"
echo "✔ .env generated"

#################################
# Inject passwords into SQL
#################################

if [ ! -f "$SQL_FILE" ]; then
  echo "⚠ $SQL_FILE not found, skipping SQL injection"
  exit 0
fi

# Load env vars
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Validate required vars
: "${N8N_DB_PASSWORD:?Missing N8N_DB_PASSWORD}"
: "${SIM_DB_PASSWORD:?Missing SIM_DB_PASSWORD}"

sed -i \
  -e "s|__N8N_DB_PASSWORD__|${N8N_DB_PASSWORD}|g" \
  -e "s|__SIM_DB_PASSWORD__|${SIM_DB_PASSWORD}|g" \
  "$SQL_FILE"

echo "✔ PostgreSQL init SQL updated"
