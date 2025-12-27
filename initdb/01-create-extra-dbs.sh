#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER n8n_user WITH ENCRYPTED PASSWORD '${N8N_DB_PASSWORD}';
    CREATE DATABASE n8n OWNER n8n_user;

    CREATE USER open_webui_user WITH ENCRYPTED PASSWORD '${OPEN_WEBUI_DB_PASSWORD}';
    CREATE DATABASE open_webui OWNER open_webui_user;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "open_webui" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS vector;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOSQL
