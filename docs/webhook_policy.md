# Webhook-Policy (Caddy/Nginx)

## Ziele

- Editor & Admin weiterhin hinter Basic-Auth
- Webhooks ohne Basic-Auth erreichbar, aber mit Rate-Limit, optional IP-Restriktion und HMAC-Check

## Caddy Quick Start

1. .env.caddy mit BASIC_USER/BASIC_HASH (und optional IP_ALLOWLIST) ausfüllen
2. Caddyfile wie geliefert deployen
3. VS Code Task "Proxy: Reload"
4. Test:
   - Ohne Auth:
     `curl -i http://localhost:8080/webhook/test`
   - Editor (ohne Auth):
     `curl -i http://localhost:8080`  # -> 401
   - Editor (mit Auth):
     `curl -i -u admin:PASS http://localhost:8080`

## HMAC-Check im Workflow

- ENV `HMAC_SECRET` auf n8n setzen
- Function-Node Snippet einfügen (nach Webhook)
- Client signiert Roh-Body mit HMAC SHA-256 (Header: X-Signature)

## Tipps

- Rate-Limits je nach Bedarf schärfen
- IP-Allowlist bei festen Partner-IP(s) aktivieren
- Secrets nie im Repo speichern; nur ENV/Secret-Store
