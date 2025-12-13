```markdown
# SkyUp – Kişisel Self-Hosted Uygulama Sunucusu

Bu repo, **skyup.online** domaini altında çeşitli açık kaynak uygulamaları güvenli bir şekilde host etmek için kullanılan sunucu konfigürasyonlarını içerir.

## Host Edilen Uygulamalar

- **skyup.online** → Ollama Web UI (Open WebUI veya benzeri) – localhost:8080
- **n8n.skyup.online** → n8n (Workflow Automation Tool) – localhost:5678
- **sim.skyup.online** → Özel Next.js uygulaması (Ana app: localhost:3001 + Socket.IO: localhost:3002)

Tüm trafikler Nginx reverse proxy üzerinden yönetilir, HTTPS (Let's Encrypt wildcard sertifika) zorunlu kılınır ve WebSocket desteği tamdır.

## Kullanılan Teknolojiler

- **Nginx** – Reverse proxy ve HTTPS termination
- **Podman** – Container orchestration (podman-compose ile)
- **Certbot** – Let's Encrypt SSL sertifikaları (wildcard *.skyup.online)

## Kurulum Adımları (Detaylı Komutlar)

1. **Gerekli Paketleri Yükle** (CentOS/RHEL/Fedora tabanlı sistemler için):
   ```bash
   dnf update -y
   dnf install nginx podman podman-compose certbot python3-certbot-nginx -y
   ```

2. **Certbot ile Wildcard SSL Sertifikası Al**  
   (Wildcard için DNS-01 doğrulaması gerekir – DNS sağlayıcında TXT kaydı eklemen gerekecek):
   ```bash
   certbot certonly --manual --preferred-challenges dns \
     -d "*.skyup.online" -d "skyup.online"
   ```
   - Certbot talimatları takip et, TXT kaydını ekle ve doğrula.
   - Sertifikalar `/etc/letsencrypt/live/skyup.online/` yoluna kaydedilir.

3. **Nginx Konfigürasyonunu Uygula**
   ```bash
   # Repo'daki nginx.conf dosyasını sunucuya kopyala
   cp nginx.conf /etc/nginx/nginx.conf   # veya conf.d/ altına skyup.conf olarak

   # Konfigürasyonu test et
   nginx -t

   # Eğer test başarılıysa Nginx'i reload et
   systemctl reload nginx
   # veya
   nginx -s reload
   ```

   Ayrıca Nginx servisini başlat ve aktif et:
   ```bash
   systemctl enable --now nginx
   ```

4. **Podman ile Container'ları Başlat**  
   (podman-compose.yaml repo'da mevcutsa):
   ```bash
   # Repo klasörüne git
   cd /path/to/skyup/repo

   # Container'ları arka planda başlat
   podman-compose up -d

   # Container durumlarını kontrol et
   podman ps -a

   # Logları izle (örnek: n8n container'ı)
   podman logs -f <container_name_or_id>
   ```

5. **DNS Ayarları**
   - Tüm subdomain'ler (`*.skyup.online` ve `skyup.online`) sunucu public IP'sine A kaydı ile yönlendirilmeli.

## Dosyalar

- `nginx.conf` → Ana reverse proxy konfigürasyonu (HTTPS, WebSocket desteği, timeout'lar vb.)
- `podman-compose.yaml` → Container tanımları ve orchestration
- `.gitignore` → Güvenlik amacıyla tüm nokta ile başlayan dosyaları (dotfiles) yok sayar  
  **Özellik**:  
  - Nokta ile başlayan tüm dosyalar (örneğin `.env`, `.private`, gizli konfigürasyonlar) otomatik olarak Git'e eklenmez ve GitHub'a yüklenmez.  
  - Tek istisna: `.gitignore` dosyasının kendisi takip edilir.

## Güvenlik Notları

- Tüm HTTP trafiği HTTPS'e yönlendirilir.
- WebSocket'ler için özel header'lar tanımlı.
- Sertifika yolları `/etc/letsencrypt/live/skyup.online/` olarak ayarlı.
- `.gitignore` sayesinde hassas dosyalar asla public repo'ya düşmez.
- Ek güvenlik header'ları (HSTS, CSP vb.) eklemek isterseniz nginx.conf'a `add_header` satırları ekleyin.

## Katkı

Her türlü öneri, hata bildirimi veya pull request hoş geldiniz! 🚀

Teşekkürler!
```
