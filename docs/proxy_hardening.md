# Production Hardening für n8n hinter Caddy

## HTTPS Aktivierung

### Domain Setup

1. Domain bei DNS-Provider auf Server-IP zeigen lassen
2. Caddyfile aktualisieren: `your-domain.tld` durch echte Domain ersetzen
3. E-Mail für Let's Encrypt setzen: `your-email@example.com`

### .env.n8n Anpassungen

```bash
N8N_SECURE_COOKIE=true
N8N_EDITOR_BASE_URL=https://your-domain.tld
WEBHOOK_URL=https://your-domain.tld
```

### Caddy Neustart

```bash
docker compose -f docker/compose.proxy.yml down
docker compose -f docker/compose.proxy.yml up -d
```

## Rate-Limiting

### Aktivierung

- In Caddyfile: `import rate` (bereits aktiviert)
- Limit: 20 Requests/Sekunde pro IP
- Anpassbar in `(rate)` Snippet

### Test

```bash
# Rate-Limit testen (mehrere Requests schnell)
for i in {1..25}; do curl -s https://your-domain.tld > /dev/null & done
```

## IP-Allowlist

### Setup

1. IPs in Caddyfile definieren:

   ```caddyfile
   @allowed {
     remote_ip 203.0.113.0/24
     remote_ip 198.51.100.42
   }
   ```

2. Handle-Block hinzufügen:

   ```caddyfile
   handle @allowed {
     reverse_proxy http://host.docker.internal:5678
   }
   handle {
     respond "Forbidden" 403
   }
   ```

### IP-Test

```bash
# Von erlaubter IP: 200
curl -I https://your-domain.tld
# Von nicht-erlaubter IP: 403
curl -I https://your-domain.tld
```

## Secrets & Rotation

### Basic-Auth

- **Rotation**: Halbjährlich mit `gen_basic_auth.sh`
- **Grace Period**: Altes Passwort 24h gültig halten
- **Storage**: Hash in `.env.caddy`, Klartext in Passwortmanager

### n8n API-Key

- **Rotation**: 90-180 Tage
- **Storage**: CI/CD Secrets, nicht im Repo
- **Update**: `.env.n8n` und Container restart

### Encryption-Key

- **Rotation**: Nur bei Security-Incident
- **Plan**: Backup → neuer Key → Daten migrieren → alter Key löschen

## Monitoring & Maintenance

### Health Checks

- Täglich: `preflight_check.sh`
- Nach Updates: Health-Workflow in n8n ausführen

### Backups

- Täglich: Volume + Config sichern
- Test: Halbmonatlich Restore durchspielen

### Updates

- n8n: LTS/aktuelle Minor bevorzugen
- Caddy: Aktuelle Version halten
- Nach Update: Alle Tests durchführen

## Smoke-Tests

```bash
# HTTP -> HTTPS Redirect
curl -I http://your-domain.tld | head

# TLS + HSTS
curl -I https://your-domain.tld | grep -Ei 'strict-transport-security|server: caddy'

# Basic-Auth (ohne Creds: 401)
curl -I https://your-domain.tld | head

# Mit Creds: 200
curl -I -u admin:DEINPASS https://your-domain.tld | head
```

## Troubleshooting

### TLS Probleme

- DNS Propagation checken: `dig your-domain.tld`
- Firewall: Port 80/443 offen?
- Logs: `docker logs caddy-n8n-proxy`

### Rate-Limit Hits

- Logs analysieren: `docker logs caddy-n8n-proxy | grep rate`
- Limit anpassen in Caddyfile

### Auth Probleme

- Hash prüfen: `docker exec caddy-n8n-proxy caddy hash-password --plaintext TESTPASS`
- ENV laden: `docker exec caddy-n8n-proxy env | grep BASIC`
