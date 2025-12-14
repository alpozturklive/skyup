#!/bin/bash

set -euo pipefail

until pg_isready -U postgres; do
  sleep 2
done


psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'sim'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE sim;"

psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'sim'" | grep -q 1 || \
  psql -U postgres -c "CREATE USER sim WITH PASSWORD '${SIM_DB_PASS}';"

psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE sim TO sim;"

psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'n8n'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE n8n;"

psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'n8n'" | grep -q 1 || \
  psql -U postgres -c "CREATE USER n8n WITH PASSWORD '${N8N_DB_PASS}';"

psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;"

psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'librechat'" | grep -q 1 || \
psql -U postgres -c "CREATE DATABASE librechat;"
psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'librechat'" | grep -q 1 || \
psql -U postgres -c "CREATE USER librechat WITH PASSWORD '${LIBRECHAT_DB_PASS}';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE librechat TO librechat;"
