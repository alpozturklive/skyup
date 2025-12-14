Understood 👍
Below are the **FINAL versions of the files** you asked for, **clean, minimal, and ready to use**.
The **README.md is intentionally short** (no excessive details).

I’m giving you **only the essential files**.

---

# ✅ `podman-compose.yml` (FINAL)

```yaml
version: "3.9"

services:

  mongodb:
    image: mongo:7
    container_name: mongodb
    restart: unless-stopped
    env_file:
      - .env
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_DB}
    command: ["mongod", "--auth"]
    ports:
      - "127.0.0.1:27017:27017"
    volumes:
      - .podman/mongodb-datadb:/data/db

  postgres:
    image: pgvector/pgvector:pg16
    container_name: postgres
    restart: unless-stopped
    env_file:
      - .env
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - .podman/pgvector-varlibpostgresqldata:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d

  librechat:
    image: ghcr.io/danny-avila/librechat:latest
    container_name: librechat
    restart: unless-stopped
    env_file:
      - .env
    environment:
      MONGO_URI: mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASSWORD}@mongodb:27017/${MONGO_DB}?authSource=admin
      OLLAMA_BASE_URL: http://ollama:11434
    volumes:
      - .podman/librechat-appclientpublicconfig:/app/client/public/config
    depends_on:
      - mongodb

  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    ports:
      - "127.0.0.1:11434:11434"
    volumes:
      - .ollama:/root/.ollama

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    env_file:
      - .env
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_DATABASE: ${N8N_DB}
      DB_POSTGRESDB_USER: ${N8N_DB_USER}
      DB_POSTGRESDB_PASSWORD: ${N8N_DB_PASSWORD}
      N8N_BASIC_AUTH_ACTIVE: "true"
      N8N_BASIC_AUTH_USER: ${N8N_BASIC_USER}
      N8N_BASIC_AUTH_PASSWORD: ${N8N_BASIC_PASSWORD}
    volumes:
      - .podman/n8n-homenode.n8n:/home/node/.n8n
    depends_on:
      - postgres

  simstudio:
    image: alpozturklive/simstudio:latest
    container_name: simstudio
    restart: unless-stopped
    env_file:
      - .env
    environment:
      DATABASE_URL: postgresql://${SIM_DB_USER}:${SIM_DB_PASSWORD}@postgres:5432/${SIM_DB}
    volumes:
      - .podman/sim-appdata:/app/data
    depends_on:
      - postgres

  realtime:
    image: alpozturklive/realtime:latest
    container_name: realtime
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - .podman/realtime-appdata:/app/data
```

---

# ✅ `init-env.sh` (FINAL)

```bash
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
```

---

# ✅ `initdb/01-postgres-init.sql` (FINAL)

```sql
CREATE DATABASE sim;
CREATE DATABASE n8n;

CREATE USER sim_user WITH PASSWORD :'SIM_DB_PASSWORD';
CREATE USER n8n_user WITH PASSWORD :'N8N_DB_PASSWORD';

GRANT ALL PRIVILEGES ON DATABASE sim TO sim_user;
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n_user;

\connect sim
CREATE EXTENSION IF NOT EXISTS vector;

\connect n8n
CREATE EXTENSION IF NOT EXISTS vector;
```

---

# ✅ `.env.example` (FORMAT ONLY)

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=
POSTGRES_DB=main

SIM_DB=sim
SIM_DB_USER=sim_user
SIM_DB_PASSWORD=

N8N_DB=n8n
N8N_DB_USER=n8n_user
N8N_DB_PASSWORD=
N8N_BASIC_USER=admin
N8N_BASIC_PASSWORD=

MONGO_ROOT_USER=mongo
MONGO_ROOT_PASSWORD=
MONGO_DB=librechat

LIBRECHAT_ADMIN_EMAIL=admin@local
LIBRECHAT_ADMIN_PASSWORD=
```

---

# ✅ `README.md` (SHORT & CLEAN)

````md
# SkyUp

Self-hosted AI and automation stack using Podman Compose.

## Services
- LibreChat
- Ollama
- MongoDB
- PostgreSQL + pgvector
- n8n
- SimStudio
- Realtime

## Setup
```bash
./init-env.sh
mkdir -p .podman/mongodb-datadb .podman/librechat-appclientpublicconfig .podman/pgvector-varlibpostgresqldata .podman/n8n-homenode.n8n .podman/sim-appdata .podman/realtime-appdata .ollama
podman-compose up -d
````

## Reset

```bash
podman-compose down
rm -rf .podman/*
podman system prune --all --force
```

```

---
