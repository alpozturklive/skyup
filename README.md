# 🌐 SkyUp – Self‑Hosted Application Stack

**Current Release:** `Release v2.1 - Memory`

This repository provides a complete self‑hosted stack for running AI applications and workflow tools on your own server using **Podman** and **podman‑compose**.

It is designed to be **simple, host‑only accessible**, and easy to extend later with security hardening if required.

**What's New in v2.1:**
- Added memory database for n8n workflow chat memory and persistent data storage
- Enhanced documentation with CLAUDE.md for AI-assisted development
- Removed deprecated simstudio service references

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

| Service      | Local URL                  | Authentication |
|--------------|----------------------------|----------------|
| Open WebUI   | `http://127.0.0.1:8080`    | User login (first user becomes admin) |
| Ollama       | `http://127.0.0.1:11434`   | None (API only) |
| n8n          | `http://127.0.0.1:5678`    | Basic Auth (see `.env` for credentials) |

### Accessing n8n

n8n is protected with basic authentication. Default credentials are stored in `.env`:
- **Username**: `admin` (stored as `N8N_BASIC_USER`)
- **Password**: Auto-generated (stored as `N8N_BASIC_PASSWORD`)

To view your n8n password:
```bash
grep N8N_BASIC_PASSWORD .env
```

### Managing Ollama Models

Ollama is configured with GPU acceleration (Vulkan). To manage models:

```bash
# List installed models
podman exec -it ollama ollama list

# Pull a new model (e.g., llama3.2)
podman exec -it ollama ollama pull llama3.2

# Remove a model
podman exec -it ollama ollama rm model-name

# Run a model directly (for testing)
podman exec -it ollama ollama run llama3.2
```

Models are stored in `/root/.ollama` on the host machine.

---

## 📸 Generating Screenshots

The `screenshots.sh` script can be used to generate screenshots of the web interfaces. This is useful for documentation or sharing your setup.

```bash
chmod +x screenshots.sh
./screenshots.sh
```

The screenshots will be saved in the `screenshots/` directory.

---

## 🔧 Troubleshooting

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

### Open WebUI Can't Connect to Ollama

If Open WebUI shows "Cannot connect to Ollama" error:

1. Check if Ollama container is running:
   ```bash
   podman ps | grep ollama
   ```

2. Verify Ollama is accessible from Open WebUI container:
   ```bash
   podman exec -it open-webui curl http://ollama:11434
   ```

3. Check Open WebUI logs:
   ```bash
   podman-compose logs open-webui
   ```

### PostgreSQL Connection Refused

If you can't connect to PostgreSQL:

1. Verify the container is running:
   ```bash
   podman ps | grep postgres
   ```

2. Check PostgreSQL logs:
   ```bash
   podman-compose logs postgres
   ```

3. Ensure you're using `127.0.0.1` when connecting from the host, and the service name `postgres` when connecting from other containers.

### 502 Bad Gateway Error from Nginx

If you receive a 502 Bad Gateway error when accessing services through Nginx, it might be due to stale DNS entries in the Nginx container. This can happen if the upstream service containers (like `n8n` or `open-webui`) are recreated and get new IP addresses.

To fix this, simply restart the Nginx container:

```bash
podman-compose restart nginx
```

This will force Nginx to re-resolve the hostnames of the upstream services.

### Application Can't Connect to Database

If an application (like n8n or Open WebUI) can't connect to the PostgreSQL database, and you have recently changed the passwords in the `.env` file, the passwords in the database will be out of sync.

To fix this, you need to update the user passwords within the PostgreSQL database to match your `.env` file. You can do this by executing `ALTER USER` commands inside the `postgres` container.

### Service Won't Start After System Reboot

Podman containers don't auto-start by default. After a system reboot:

```bash
cd /path/to/skyup
podman-compose up -d
```

To enable auto-start on boot, you can create a systemd service or use Podman's auto-update feature.

### Viewing Service Logs

To troubleshoot any service:

```bash
# View logs for all services
podman-compose logs

# View logs for a specific service
podman-compose logs [service-name]

# Follow logs in real-time
podman-compose logs -f [service-name]

# View last 50 lines
podman-compose logs --tail=50 [service-name]
```

---

## 🔌 PostgreSQL Connections

PostgreSQL runs with the pgvector extension and hosts four databases:

| Database | Owner | Purpose |
|----------|-------|---------|
| `postgres` | postgres | Admin database |
| `n8n` | n8n_user | n8n workflow metadata and credentials |
| `open_webui` | open_webui_user | Open WebUI data (includes vector and uuid-ossp extensions) |
| `memory` | memory_user | n8n workflow chat memory and persistent data storage |

### Connect from host (admin)

```bash
psql -h 127.0.0.1 -p 5432 -U postgres postgres
```

Password is stored in `.env` as `POSTGRES_PASSWORD`.

### Connect to application databases

```bash
# n8n database (workflow metadata)
psql -h 127.0.0.1 -U n8n_user n8n

# Open WebUI database (user data, conversations)
psql -h 127.0.0.1 -U open_webui_user open_webui

# Memory database (for n8n workflows)
psql -h 127.0.0.1 -U memory_user memory
```

Passwords for each database user are stored in the `.env` file.

### Using the memory database in n8n workflows

The memory database is specifically designed for n8n workflows to store:
- Chat conversation history
- Persistent workflow data
- Custom application data

**Connection details from within n8n:**
- **Host**: `postgres` (use service name, not localhost)
- **Port**: `5432`
- **Database**: `memory`
- **User**: `memory_user`
- **Password**: Use the `MEMORY_DB_PASSWORD` from your `.env` file

**Connection string format:**
```
postgresql://memory_user:YOUR_PASSWORD@postgres:5432/memory
```

---

## 🧾 Backup and Restore

### Creating a Backup

A simple way to back up your stack's configuration and persistent data is to create a tarball of the essential files and directories:

```bash
tar -czf skyup-backup-$(date +%F).tar.gz \
  .podman/ .env podman-compose.yml initdb/ nginx.conf
```

This backup includes:
- All database data (PostgreSQL)
- Open WebUI data
- n8n workflows and credentials
- Ollama models (note: can be large!)
- Configuration files

### Restoring from Backup

1. Stop all services:
   ```bash
   podman-compose down
   ```

2. Extract the backup:
   ```bash
   tar -xzf skyup-backup-YYYY-MM-DD.tar.gz
   ```

3. Restart services:
   ```bash
   podman-compose up -d
   ```

### Database-Only Backups

For PostgreSQL database backups:

```bash
# Backup all databases
podman exec postgres pg_dumpall -U postgres > skyup-db-backup-$(date +%F).sql

# Backup specific database
podman exec postgres pg_dump -U postgres n8n > n8n-backup-$(date +%F).sql

# Restore database
cat skyup-db-backup-YYYY-MM-DD.sql | podman exec -i postgres psql -U postgres
```

## 🚀 Production Deployment with HTTPS

The stack includes Nginx for production deployments with HTTPS support.

### Prerequisites

1. Domain name pointing to your server (e.g., `skyup.online`, `n8n.skyup.online`)
2. Ports 80 and 443 open in your firewall
3. Certbot installed on the host

### Steps

1. **Update nginx.conf** with your domain names:
   ```bash
   # Edit nginx.conf and replace skyup.online with your domain
   nano nginx.conf
   ```

2. **Obtain SSL certificates** using certbot:
   ```bash
   sudo certbot certonly --nginx -d skyup.online -d n8n.skyup.online
   ```

3. **Restart Nginx** to apply changes:
   ```bash
   podman-compose restart nginx
   ```

4. **Set up auto-renewal** for certificates:
   ```bash
   # Test renewal
   sudo certbot renew --dry-run

   # Certificates auto-renew via systemd timer
   sudo systemctl status certbot-renew.timer
   ```

Your services will now be accessible via HTTPS:
- Open WebUI: `https://skyup.online`
- n8n: `https://n8n.skyup.online`

## 📊 Service Management

### Checking Service Status

```bash
# View all running containers
podman ps

# Check specific service status
podman-compose ps

# Check service health
podman inspect --format='{{.State.Health.Status}}' open-webui
```

### Restarting Services

```bash
# Restart all services
podman-compose restart

# Restart specific service
podman-compose restart [service-name]

# Stop and start (full restart)
podman-compose down && podman-compose up -d
```

### Updating Services

To update to the latest container images:

```bash
# Pull latest images
podman-compose pull

# Recreate containers with new images
podman-compose up -d --force-recreate
```

### Resource Usage

```bash
# View resource usage for all containers
podman stats

# View resource usage for specific container
podman stats ollama
```

---

## ❓ Frequently Asked Questions

### How do I change the n8n admin password?

The n8n password is stored in the `.env` file as `N8N_BASIC_PASSWORD`. To change it:

1. Edit `.env` and update `N8N_BASIC_PASSWORD`
2. Restart n8n: `podman-compose restart n8n`

### Can I access these services from other machines on my network?

By default, services bind to `127.0.0.1` (localhost only). To expose them to your network:

1. Edit `podman-compose.yml`
2. Change ports from `127.0.0.1:PORT:PORT` to `0.0.0.0:PORT:PORT`
3. Restart services: `podman-compose up -d`

**Security Note:** Only do this on trusted networks, or set up proper authentication and firewalls.

### How do I add more Ollama models?

```bash
# Pull a model (this may take several minutes)
podman exec -it ollama ollama pull llama3.2

# Verify it's installed
podman exec -it ollama ollama list
```

The model will automatically appear in Open WebUI.

### Where are Ollama models stored?

Models are stored in `/root/.ollama` on the host machine. This directory is bind-mounted into the Ollama container.

### Can I use this with Docker instead of Podman?

Yes! The `podman-compose.yml` file is compatible with Docker Compose. Simply replace `podman-compose` with `docker-compose` in all commands.

### How do I reset everything and start fresh?

```bash
# Stop all services
podman-compose down

# Run the init script (this will reset data directories)
./init-env.sh

# Start services
podman-compose up -d
```

**Warning:** This will delete all your data! Make a backup first if needed.

### How much disk space do I need?

- Base stack: ~2-5 GB
- Each Ollama model: 2-40 GB depending on model size
- Your data (conversations, workflows): Varies

Recommended: At least 50 GB free disk space.

### Does this work on Ubuntu/Debian?

Yes, but install instructions differ:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y podman podman-compose nginx certbot python3-certbot-nginx
```

---

## 🤝 Contributing

Pull requests and issues are welcome at https://github.com/alpozturklive/skyup

---

## 📄 License

MIT License
