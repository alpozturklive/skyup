#!/bin/bash

set -euo pipefail

echo "init-dbs.sh başlatılıyor..."

until pg_isready -U postgres; do
  echo "Postgres hazır değil, bekleniyor..."
  sleep 2
done

echo "Veritabanları ve user'lar oluşturuluyor..."

# SimStudio veritabanı ve user
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'simstudio'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE simstudio;"

psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'sim'" | grep -q 1 || \
  psql -U postgres -c "CREATE USER sim WITH PASSWORD '${SIM_DB_PASS}';"

psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE simstudio TO sim;"

# n8n veritabanı ve user
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'n8n'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE n8n;"

psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'n8n'" | grep -q 1 || \
  psql -U postgres -c "CREATE USER n8n WITH PASSWORD '${N8N_DB_PASS}';"

psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;"

echo "Ayrı veritabanları başarıyla oluşturuldu!"