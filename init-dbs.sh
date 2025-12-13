#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
-- n8n kurulumu
CREATE DATABASE n8n;
CREATE USER n8n WITH ENCRYPTED PASSWORD '${N8N_DB_PASS}';
ALTER DATABASE n8n OWNER TO n8n;
GRANT ALL ON DATABASE n8n TO n8n;

-- Sim kurulumu
CREATE DATABASE sim;
CREATE USER sim WITH ENCRYPTED PASSWORD '${SIM_DB_PASS}';
ALTER DATABASE sim OWNER TO sim;
GRANT ALL ON DATABASE sim TO sim;

-- pgvector kurulumu
\c sim
CREATE EXTENSION vector;
\c postgres
EOSQL
