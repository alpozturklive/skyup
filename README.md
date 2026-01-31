# 🌐 SkyUp – Self‑Hosted Application Stack

**Current Release:** `Release v2.0 - Horizon`

This repository provides a complete self‑hosted stack for running AI applications and workflow tools on your own server using **Podman** and **podman‑compose**.

It is designed to be **simple, host‑only accessible**, and easy to extend later with security hardening if required.

---

## 📦 Included Services

| Service               | Purpose                 | Default Port   |
| --------------------- | ----------------------- | -------------- |
| **PostgreSQL**        | Vector-enabled database | `5432`         |
| **Ollama**            | Local LLM service       | `11434`        |
| **Open WebUI**        | AI chat interface       | `8080`         |
| **n8n**               | Workflow automation     | `5678`         |
| **Nginx**             | Reverse proxy + HTTPS   | `80` / `443`    |

-   **PostgreSQL (pgvector):** A powerful, open-source object-relational database system with vector similarity search capabilities.
-   **Ollama:** A service for running large language models locally.
-   **Open WebUI:** A user-friendly and feature-rich web interface for interacting with local Large Language Models (LLMs).
-   **n8n:** A workflow automation tool that allows you to connect different applications and services to create powerful, automated workflows.
-   **Nginx:** A high-performance reverse proxy to route traffic to the appropriate services, with HTTPS support for production deployments.

---

## 🚀 Prerequisites

Install required packages:

```bash
# Fedora / RHEL / CentOS
sudo dnf install -y podman podman-compose nginx certbot python3-certbot-nginx
```

Ensure:
- Podman is running
- For production, DNS records point to your server and ports 80 and 443 are open.

---

## ⚙️ Setup Instructions

### 1️⃣ Generate Environment Variables

First, make the initialization script executable:
```bash
chmod +x init-env.sh
```

Then, run the script to generate the `.env` file and create required data directories:
```bash
./init-env.sh
```
This script will create strong, random passwords for your services and store them in the `.env` file.

### 2️⃣ Start the Services

Start the entire application stack in the background:
```bash
podman-compose up -d
```

### 3️⃣ Create an Admin User (Open WebUI)

The first user to register in Open WebUI automatically becomes an admin. Navigate to the Open WebUI service (e.g., `http://127.0.0.1:8080`) and create your account.

---

## 🌍 Accessing Services Locally

The services are configured to be accessible only from the host machine (`127.0.0.1`). This is for simplicity and security.

| Service      | Local URL                  |
|--------------|----------------------------|
| Open WebUI   | `http://127.0.0.1:8080`    |
| Ollama       | `http://127.0.0.1:11434`   |
| n8n          | `http://127.0.0.1:5678`    |

---

## 📸 Generating Screenshots

The `screenshots.sh` script can be used to generate screenshots of the web interfaces. This is useful for documentation or sharing your setup.

```bash
chmod +x screenshots.sh
./screenshots.sh
```

The screenshots will be saved in the `screenshots/` directory.

---

##  troubleshooting

### n8n Crash Loop (Permission Denied)

If the `n8n` service enters a crash loop, it is likely due to a file permission error on its data volume. The container runs as a non-root user and may not have permission to write to the `.podman/n8n-homenode.n8n` directory.

To fix this, change the ownership of the directory on the host:

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

---

## 🧾 Backup Recommendation

A simple way to back up your stack's configuration and persistent data is to create a tarball of the essential files and directories:

```bash
tar -czf skyup-backup-$(date +%F).tar.gz \
  .podman/ .env podman-compose.yml initdb/ nginx.conf
```

---

## 🤝 Contributing

Pull requests and issues are welcome.

---

## 📄 License

MIT License
