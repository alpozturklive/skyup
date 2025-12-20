# 🌐 SkyUp – Self‑Hosted Application Stack

This repository provides a complete self‑hosted stack for running AI applications and workflow tools on your own server using **Podman** and **podman‑compose**.

It is designed to be **simple, host‑only accessible**, and easy to extend later with security hardening if required.

---

## 📦 Included Services

| Service | Purpose | Default Port |
|------|--------|--------------|
| PostgreSQL (pgvector) | Vector‑enabled database | 5432 |
| LibreChat | AI chat interface | 3080 |
| n8n | Workflow automation | 5678 |
| SimStudio AI | AI agent workflows | 3000 / 3001 |
| Nginx | Reverse proxy + HTTPS | 80 / 443 |

---

## 🚀 Prerequisites

Install required packages:

```bash
# Fedora / RHEL / CentOS
sudo dnf install -y podman podman-compose nginx certbot python3-certbot-nginx
```

Ensure:
- Podman is running
- DNS records point to your server
- Ports 80 and 443 are open

---

## 📂 Repository Structure

```text
.
├── podman-compose.yml
├── .env
├── init-env.sh
├── initdb/
│   ├── 01-create-extra-dbs.sql
│   └── 02-enable-extensions.sql
├── nginx.conf
└── .podman/
```

---

## ⚙️ Setup Instructions

### 1️⃣ Create required directories

```bash
mkdir -p .podman/pgvector-varlibpostgresqldata
```

---

### 2️⃣ Generate environment variables

```bash
chmod +x init-env.sh
./init-env.sh
```

This generates:
- Strong passwords
- JWT secrets
- Database credentials

All secrets are stored in `.env`.

---

### 3️⃣ PostgreSQL initialization

PostgreSQL uses the image:

```yaml
pgvector/pgvector:pg16
```

On first startup, SQL files inside `initdb/` are executed automatically:

- **01-create-extra-dbs.sql**
  - Creates `n8n` and `sim` databases and users
- **02-enable-extensions.sql**
  - Enables extensions per database

Enabled extensions:
- `vector`
- `uuid-ossp`
- `pgcrypto`
- `citext`

---

### 4️⃣ Start services

```bash
podman-compose up -d
```

---

## 🔌 PostgreSQL Connections

### Connect from host (admin)

```bash
psql -h 127.0.0.1 -p 5432 -U postgres postgres
```

### Connect to application databases

```bash
psql -h 127.0.0.1 -U n8n_user n8n
psql -h 127.0.0.1 -U sim_user sim
```

### List databases

```bash
\l
```

### List enabled extensions

```bash
\dx
```

---

## 🌍 Access Services

| Service | URL |
|------|----|
| LibreChat | https://skyup.online |
| n8n | https://n8n.skyup.online |
| SimStudio | https://sim.skyup.online |

---

## 🧾 Backup Recommendation

```bash
tar -czf skyup-backup-$(date +%F).tar.gz \
  .podman/ .env podman-compose.yml initdb/ nginx.conf
```

---

## 📌 Notes

- PostgreSQL is **host‑only accessible** via `127.0.0.1`
- Init SQL scripts run **only on first startup**
- No security hardening is applied intentionally

---

## 🤝 Contributing

Pull requests and issues are welcome.

---

## 📄 License

MIT License
