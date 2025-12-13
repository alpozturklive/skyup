```markdown
# SkyUp – Kişisel Self-Hosted Uygulama Sunucusu

Bu repo, **skyup.online** domaini altında güçlü açık kaynak araçları güvenli bir şekilde host etmek için hazırlanmış tam bir konfigürasyon setidir.

## Host Edilen Uygulamalar

- **skyup.online** → Ollama Web UI (Open WebUI) – Güçlü LLM modellerini tarayıcıdan yönetin (localhost:8080)
- **n8n.skyup.online** → n8n – Görsel workflow automation aracı (localhost:5678)
- **sim.skyup.online** → SimStudio AI – AI agent workflow builder (Next.js tabanlı, ana app: 3000, realtime/socket: 3001)

Tüm trafiği Nginx reverse proxy yönetir, Let's Encrypt wildcard SSL ile HTTPS zorunlu kılınır ve WebSocket desteği tamdır.

## Kullanılan Teknolojiler

- **Podman + podman-compose** – Rootless container orchestration
- **Nginx** – Reverse proxy ve HTTPS termination
- **PostgreSQL with pgvector** – SimStudio ve n8n için ayrı veritabanları
- **Let's Encrypt** – Wildcard SSL (*.skyup.online)

## Kurulum ve Kullanım Adımları

1. **Gerekli Paketleri Yükle** (CentOS/RHEL/Fedora için):
   ```bash
   dnf update -y
   dnf install podman podman-compose nginx certbot python3-certbot-nginx -y
   ```

2. **Repo'yu Klonla ve Dizine Gir** (proje /root içinde olacak):
   ```bash
   cd /root
   git clone https://github.com/alpozturklive/skyup.git .
   # veya mevcut repo'yu güncelle: git pull
   ```

3. **Gizli Klasörü Oluştur** (tüm kalıcı veriler burada tutulur):
   ```bash
   mkdir -p .podman/{pgvector-varlibpostgresqldata,simstudio-appdata,realtime-appdata,n8n-homenode.n8n,open-webui-appbackenddata,ollama-models}
   ```

4. **Güvenli .env Dosyasını Oluştur** (tüm şifreler otomatik üretilir, =+/ karakterleri içermez):
   ```bash
   chmod +x init-env.sh
   ./init-env.sh
   ```

5. **Container'ları Başlat**:
   ```bash
   chmod +x init-dbs.sh
   podman-compose up -d
   ```

   - İlk başlatmada `init-dbs.sh` otomatik çalışır ve ayrı veritabanlarını (`simstudio` ve `n8n`) oluşturur.

6. **Nginx Konfigürasyonunu Uygula**:
   ```bash
   cp nginx.conf /etc/nginx/nginx.conf   # veya /etc/nginx/conf.d/skyup.conf olarak
   nginx -t                              # konfigürasyonu test et
   systemctl reload nginx
   systemctl enable --now nginx
   ```

7. **SSL Sertifikası Al** (Wildcard için DNS-01 önerilir):
   ```bash
   certbot certonly --manual --preferred-challenges dns -d "*.skyup.online" -d skyup.online
   ```
   - DNS sağlayıcında TXT kaydı ekle, sertifikalar `/etc/letsencrypt/live/skyup.online/` altına kaydedilir.

8. **DNS Ayarları**
   - `skyup.online` ve `*.skyup.online` A kayıtlarını sunucu public IP'sine yönlendir.

## Kullanım ve Giriş

- **SimStudio** (https://sim.skyup.online)
  - Sign up linkine tıkla → Email ve şifre ile yeni hesap oluştur.
  - İlk hesap admin olur.
  - AI agent workflow'ları visual olarak tasarlayabilirsin.

- **n8n** (https://n8n.skyup.online)
  - Basic Auth ile giriş: Kullanıcı `admin`, şifre `./init-env.sh` çalıştırıldığında üretilen (`cat .env | grep N8N_BASIC_AUTH_PASS`)
  - Workflow'lar oluştur, API'leri bağla.

- **Ollama WebUI** (https://skyup.online)
  - Email: `admin@local`
  - Şifre: `./init-env.sh` ile üretilen (`cat .env | grep WEBUI_ADMIN_PASSWORD`)
  - Modelleri indir, chat yap, API kullan.

## Günlük Kullanım Komutları

- Container'ları durdur/başlat:
  ```bash
  podman-compose down
  podman-compose up -d
  ```

- Logları izle:
  ```bash
  podman logs -f simstudio
  podman logs -f n8n
  podman logs -f open-webui
  ```

- Yeni şifreler üret (.env yenile):
  ```bash
  ./init-env.sh
  podman-compose restart
  ```

- Backup al:
  ```bash
  tar -czf skyup-backup-$(date +%F).tar.gz .podman/ .env podman-compose.yaml nginx.conf init-*.sh
  ```

## Güvenlik Notları

- `.env` ve `.podman/` klasörü `.gitignore` ile korunur, asla GitHub'a yüklenmez.
- Tüm şifreler rastgele ve güçlüdür.
- Kayıt kapatma (`DISABLE_REGISTRATION=true`) ile sadece ilk kullanıcı giriş yapabilir.
- Firewall'da sadece 80/443 açık olmalı.

Her türlü öneri, hata bildirimi veya katkı hoş geldiniz! 🚀

Teşekkürler – Alparslan Öztürk
```

Bu README.md dosyasını doğrudan repo köküne (`/root/README.md`) koyabilirsin:

```bash
nano README.md
# yukarıdaki içeriği yapıştır, kaydet
git add README.md
git commit -m "Add detailed README with usage instructions"
git push origin main
```

Artık repo'n hem profesyonel görünecek hem de başka biri (veya gelecekteki sen) kolayca kurup kullanabilecek. İyi eğlenceler! 🚀