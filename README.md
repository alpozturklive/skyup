```markdown
# SkyUp – Kişisel Self-Hosted Uygulama Sunucusu

Bu repo, **skyup.online** domaini altında güçlü açık kaynak araçları güvenli bir şekilde host etmek için hazırlanmış tam bir konfigürasyon setidir.

## Host Edilen Uygulamalar

- **skyup.online** → Ollama Web UI (Open WebUI) – Güçlü LLM modellerini tarayıcıdan yönetin
- **n8n.skyup.online** → n8n – Görsel workflow automation aracı
- **sim.skyup.online** → SimStudio AI – AI agent workflow builder (Next.js tabanlı)

Tüm trafiği Nginx reverse proxy yönetir, Let's Encrypt wildcard SSL ile HTTPS zorunlu kılınır ve WebSocket desteği tamdır.

## Kullanılan Teknolojiler

- **Podman + podman-compose** – Rootless container orchestration
- **Nginx** – Reverse proxy ve HTTPS termination
- **PostgreSQL with pgvector** – SimStudio ve n8n için **ayrı** veritabanları
- **Let's Encrypt** – Wildcard SSL (*.skyup.online)

## Tam Kurulum ve Kullanım Adımları

Aşağıdaki adımları **sırayla** çalıştırın (hepsi /root dizininde yapılır).

1. **Gerekli Paketleri Yükle** (CentOS/RHEL/Fedora için):
   ```bash
   dnf update -y
   dnf install podman podman-compose nginx certbot python3-certbot-nginx -y
   ```

2. **Repo'yu Hazırla** (eğer daha önce klonlamadıysan):
   ```bash
   cd /root
   git clone https://github.com/alpozturklive/skyup.git .
   # veya mevcut repo'yu güncelle:
   git pull
   ```

3. **Kalıcı Veri Klasörlerini Oluştur** (tüm veriler burada tutulur):
   ```bash
   mkdir -p .podman/{pgvector-varlibpostgresqldata,simstudio-appdata,realtime-appdata,n8n-homenode.n8n,open-webui-appbackenddata,ollama-models}
   ```

4. **Güvenli .env Dosyasını Oluştur** (tüm şifreler otomatik ve güçlü üretilir):
   ```bash
   chmod +x init-env.sh
   ./init-env.sh
   ```
   - `.env` dosyası repo kökünde oluşur ve `.gitignore` ile korunur (GitHub'a yüklenmez).

5. **Veritabanı Init Script'ini Hazırla**:
   ```bash
   chmod +x init-dbs.sh
   ```

6. **Container'ları Başlat**:
   ```bash
   podman-compose up -d
   ```
   - İlk başlatmada `init-dbs.sh` otomatik çalışır ve şu veritabanlarını oluşturur:
     - `simstudio` (SimStudio için, user: sim)
     - `n8n` (n8n için, user: n8n)

7. **Nginx Konfigürasyonunu Uygula**:
   ```bash
   cp nginx.conf /etc/nginx/nginx.conf   # veya /etc/nginx/conf.d/skyup.conf olarak
   nginx -t                              # konfigürasyonu test et
   systemctl reload nginx
   systemctl enable --now nginx
   ```

8. **SSL Sertifikası Al** (Wildcard için DNS-01 önerilir):
   ```bash
   certbot certonly --manual --preferred-challenges dns -d "*.skyup.online" -d skyup.online
   ```
   - DNS sağlayıcında TXT kaydı ekle, sertifikalar `/etc/letsencrypt/live/skyup.online/` altına kaydedilir.

9. **DNS Ayarları**
   - `skyup.online` ve `*.skyup.online` A kayıtlarını sunucu public IP'sine yönlendir.

## Uygulamalara Giriş ve Kullanım

- **SimStudio** (https://sim.skyup.online)
  - "Sign up" linkine tıklayın → Email ve şifre ile yeni hesap oluşturun.
  - İlk hesap otomatik admin olur.
  - AI agent'ları visual olarak tasarlayın.

- **n8n** (https://n8n.skyup.online)
  - Basic Auth ile giriş yapın:
    - Kullanıcı: `admin`
    - Şifre: `.env` dosyasında `N8N_BASIC_AUTH_PASS` satırındaki değer  
      (görmek için: `grep N8N_BASIC_AUTH_PASS .env`)
  - Workflow'lar oluşturun, entegrasyonlar ekleyin.

- **Ollama WebUI** (https://skyup.online)
  - Email: `admin@local`
  - Şifre: `.env` dosyasında `WEBUI_ADMIN_PASSWORD` satırındaki değer  
    (görmek için: `grep WEBUI_ADMIN_PASSWORD .env`)
  - Modelleri indirin, chat yapın, Ollama API'sini kullanın.

## Günlük Kullanım ve Bakım Komutları

- Container'ları yeniden başlat:
  ```bash
  podman-compose down
  podman-compose up -d
  ```

- Logları izle:
  ```bash
  podman logs -f simstudio
  podman logs -f n8n
  podman logs -f open-webui
  podman logs -f pgvector
  ```

- Yeni şifreler üret ve hizmetleri yenile:
  ```bash
  ./init-env.sh
  podman-compose restart
  ```

- Backup al (tüm veriler + konfigürasyon):
  ```bash
  tar -czf skyup-backup-$(date +%F).tar.gz .podman/ .env podman-compose.yaml nginx.conf init-env.sh init-dbs.sh
  ```

- Verileri tamamen temizle (sıfırdan başlamak için):
  ```bash
  podman-compose down
  rm -rf .podman/*
  ```

- **Podman Sistemini Temizle** (kullanılmayan image, container, volume ve network'leri sil – dikkatli kullan!):
  ```bash
  podman system prune --all --force
  ```
  - `--all`: Kullanılmayan tüm image'ları da siler.
  - `--force`: Onay sormadan çalıştırır.
  - Bu komut disk alanı boşaltmak için idealdir ama aktif container'ları etkilemez.

## Güvenlik Notları

- `.env` ve `.podman/` klasörü `.gitignore` ile korunur, asla public repo'ya düşmez.
- Tüm şifreler rastgele ve güçlüdür (=+/ karakterleri içermez).
- `DISABLE_REGISTRATION=true` ile SimStudio'da yeni kayıt kapatılmıştır.
- Firewall'da sadece 80 ve 443 portları açık olmalı.

Her türlü öneri, hata bildirimi veya katkı hoş geldiniz! 🚀

**Teşekkürler – Alparslan Öztürk**
```

Bu güncellenmiş README.md'yi repo'na koy (önceki içeriğin üzerine yaz):

```bash
cd /root
nano README.md
# yukarıdaki tüm içeriği yapıştır, kaydet

git add README.md
git commit -m "Update README: add podman system prune command and maintenance section"
git push origin main
```

Artık README'n **podman system prune --all** komutunu da içeren tam bir bakım rehberi oldu. Disk alanı dolduğunda bu komutla kolayca temizlik yapabilirsin.

Her şey tamam – setup'ın mükemmel! 🚀