# 🌐 SkyUp – Self‑Hosted Application Stack

This repository provides a complete self‑hosted stack for running AI applications and workflow tools on your own server using **Podman** and **podman‑compose**.

It is designed to be **simple, host‑only accessible**, and easy to extend later with security hardening if required.

---

## 📦 Included Services

| Service | Purpose | Default Port |
|------|--------|--------------|
| PostgreSQL (pgvector) | Vector‑enabled database | 5432 |
| Open WebUI | AI chat interface | 8080 |
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
│   └── 01-create-extra-dbs.sh
├── nginx.conf
└── .podman/
```

---

## ⚙️ Setup Instructions

### 1️⃣ Generate environment variables and create directories

```bash
chmod +x init-env.sh
./init-env.sh
```

This script performs two key functions:
- **Creates/Resets directories:** It creates the required `.podman` data structure. On subsequent runs, it will reset the data for all services *except* Open WebUI, whose data is preserved to maintain users and settings.
- **Generates/Updates secrets:** It creates strong passwords and credentials, storing them securely in the `.env` file. If `.env` already exists, it will reuse any existing passwords to avoid breaking current configurations.

---

### 2️⃣ PostgreSQL initialization
---

##  troubleshooting

### n8n Crash Loop (Permission Denied)

If the `n8n` service enters a crash loop immediately after starting, it is likely due to a file permission error on its data volume. The container runs as a non-root user and may not have permission to write to the `.podman/n8n-homenode.n8n` directory.

To fix this, change the ownership of the directory on the host to the correct user ID (typically `1000` for the `node` user):

```bash
sudo chown -R 1000:1000 .podman/n8n-homenode.n8n
```

After changing the ownership, restart the services:

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
psql -h 127.0.0.1 -U open_webui_user open_webui
```

### List databases

```bash
\l
```

### List enabled extensions

Connect to a database first, then run:
```bash
\dx
```

---

## 🌍 Access Services

| Service | URL |
|------|----|
| Open WebUI | https://skyup.online |
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
