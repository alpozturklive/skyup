#!/bin/bash

# init-dbs.sh - Postgres container'ında ilk başlatmada çalışır
# simstudio ve n8n için ayrı veritabanları ve user'lar oluşturur

set -euo pipefail

echo "init-dbs.sh başlatılıyor..."

# Postgres tamamen hazır olana kadar bekle
until pg_isready -U postgres; do
  echo "Postgres hazır değil, bekleniyor..."
  sleep 2
done

# .env dosyasını yükle (repo kökünde olduğu için doğrudan source edilebilir)
if [ -f .env ]; then
  source .env
else
  echo "Hata: .env dosyası bulunamadı!"
  exit 1
fi

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

echo "Ayrı veritabanları başarıyla oluşturuldu:"
echo "  - simstudio (user: sim)"
echo "  - n8n (user: n8n)"
echo "init-dbs.sh tamamlandı!"