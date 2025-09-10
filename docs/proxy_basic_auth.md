# Basic-Auth vor n8n (Caddy)

## Setup in 60 Sekunden

1. Hash erzeugen:
   `bash ops/scripts/gen_basic_auth.sh`
   -> BASIC_USER / BASIC_HASH in .env.caddy schreiben

2. Proxy starten:
   `docker compose -f docker/compose.proxy.yml up -d`

3. Test:
   - Ohne Login: `curl -i http://localhost:8080 | head`  # -> 401, kein n8n-Login sichtbar
   - Mit Login: `curl -u admin:PASS http://localhost:8080`  # -> 200 / n8n UI

## Betrieb

- Änderungen am Caddyfile:
  VS Code → Run Task → "Proxy: Reload"
- Später HTTPS aktivieren:
  Caddyfile auf domain.tld ändern, :443 verwenden.
- Sicherheit:
  - Passwort nur im Passwortmanager aufbewahren.
  - .env.caddy nie committen.
  - Bei öffentlicher Erreichbarkeit zusätzlich Rate-Limits / IP-Filter erwägen.
