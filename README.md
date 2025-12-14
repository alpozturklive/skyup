
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
mkdir -p .podman/{mongodb-datadb,librechat-appclientpublicconfig,pgvector-varlibpostgresqldata,n8n-homenode.n8n,sim-appdata,realtime-appdata}
chown -R 1000:1000 .podman/n8n-homenode.n8n
podman-compose up -d
````

## Reset

```bash
podman-compose down
rm -rf .podman
podman system prune --all --force
```



---
