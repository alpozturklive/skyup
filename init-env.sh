#!/bin/bash

# init-env.sh - SimStudio, n8n ve Ollama WebUI için güvenli .env dosyası oluşturur
# "=+/" karakterlerini tamamen dışlar (base64 güvenli hale getirilir)

set -euo pipefail

# Güvenli rastgele değer üretimi (32-48 byte, =+/ dışlanır)
generate_secret() {
    local length=$1
    openssl rand -base64 $((length * 4 / 3 + 4)) | tr -d "=+/" | head -c $length
}

# Değerleri üret
POSTGRES_ROOT_PASS=$(generate_secret 32)
N8N_DB_PASS=$(generate_secret 32)
SIM_DB_PASS=$(generate_secret 32)
N8N_BASIC_AUTH_PASS=$(generate_secret 24)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)                    # hex zaten güvenli
SIM_JWT_SECRET=$(generate_secret 48)
NEXTAUTH_SECRET=$(generate_secret 48)
BETTER_AUTH_SECRET=$(openssl rand -hex 32)                   # hex güvenli
WEBUI_ADMIN_PASSWORD=$(generate_secret 32)
INITIAL_USER_PASSWORD=$(generate_secret 32)

# Sabit değerler
NEXT_PUBLIC_APP_URL="https://sim.skyup.online"
N8N_BASIC_AUTH_USER="admin"
WEBUI_ADMIN_EMAIL="admin@local"
INITIAL_USER_EMAIL="admin@local"

# .env dosyasını oluştur (varsa üzerine yazar)
cat > .env <<EOF
# Database
POSTGRES_ROOT_PASS=${POSTGRES_ROOT_PASS}
SIM_DB_PASS=${SIM_DB_PASS}
N8N_DB_PASS=${N8N_DB_PASS}

# n8n Security
N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
N8N_BASIC_AUTH_PASS=${N8N_BASIC_AUTH_PASS}
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

# SimStudio Auth Secrets
SIM_JWT_SECRET=${SIM_JWT_SECRET}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
BETTER_AUTH_SECRET=${BETTER_AUTH_SECRET}

# Ollama WebUI (Open WebUI) Initial Admin
WEBUI_ADMIN_EMAIL=${WEBUI_ADMIN_EMAIL}
WEBUI_ADMIN_PASSWORD=${WEBUI_ADMIN_PASSWORD}

# SimStudio Initial User (Better Auth)
INITIAL_USER_EMAIL=${INITIAL_USER_EMAIL}
INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD}

# App URLs
NEXT_PUBLIC_APP_URL=${NEXT_PUBLIC_APP_URL}

# Security & Features
DISABLE_REGISTRATION=true                  # İlk kullanıcıdan sonra kayıt kapat
OTEL_SDK_DISABLED=true                     # Telemetriyi kapat
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_RUNNERS_ENABLED=true
N8N_BLOCK_ENV_ACCESS_IN_NODE=true
N8N_GIT_NODE_DISABLE_BARE_REPOS=true

# Ekstra (isteğe bağlı ama önerilen)
BETTER_AUTH_URL=${NEXT_PUBLIC_APP_URL}
NEXTAUTH_URL=${NEXT_PUBLIC_APP_URL}
EOF

echo ".env dosyası başarıyla oluşturuldu!"
echo "Oluşturulan değerler tamamen rastgele ve =+/ karakterleri içermiyor."
echo ""
echo "Şimdi container'ları başlatabilirsin:"
echo "   podman-compose up -d"
echo ""
echo "İlk giriş için:"
echo "   SimStudio → Sign up ile ${INITIAL_USER_EMAIL} ve üretilen şifreyle kayıt ol"
echo "   Ollama WebUI → ${WEBUI_ADMIN_EMAIL} / üretilen şifre"
echo "   n8n → ${N8N_BASIC_AUTH_USER} / üretilen şifre (basic auth)"