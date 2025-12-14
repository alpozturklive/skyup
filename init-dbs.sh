#!/bin/bash

set -euo pipefail

until pg_isready -U postgres; do
sleep 2
done

# 1. Create Databases
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'sim'" | grep -q 1 || \
psql -U postgres -c "CREATE DATABASE sim;"

psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'n8n'" | grep -q 1 || \
psql -U postgres -c "CREATE DATABASE n8n;"

# 2. Create Dedicated Users with Static Passwords
psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'sim_user'" | grep -q 1 || \
psql -U postgres -c "CREATE USER sim_user WITH PASSWORD 'simpass';"

psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'n8n_user'" | grep -q 1 || \
psql -U postgres -c "CREATE USER n8n_user WITH PASSWORD 'n8npass';"

# 3. Grant Permissions
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE sim TO sim_user;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n_user;"

# 4. Enable pgvector Extension
psql -U postgres -d sim -c "CREATE EXTENSION IF NOT EXISTS vector;"
psql -U postgres -d n8n -c "CREATE EXTENSION IF NOT EXISTS vector;"

echo "Database initialization completed."