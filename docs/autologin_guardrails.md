# Auto-Login Guardrails für n8n (Variante A)

## Ziel

Immer direkt ins Dashboard ohne Setup-Wizard, mit langer Session und sicherer Konfiguration.

## .env.n8n Konfiguration

- `N8N_ENCRYPTION_KEY`: 32-Zeichen HEX (bereits gesetzt)
- `N8N_USER_MANAGEMENT_JWT_DURATION_HOURS=720` (30 Tage Session)
- `N8N_SECURE_COOKIE=false` (lokal HTTP, bei HTTPS später true)

## Persistenz sichern

- Volume bleibt auf `/home/node/.n8n` gemountet
- Owner einmal anlegen → kein Wizard mehr
- Keine Volume-Resets bei ENV-Änderungen

## Backups

- Tägliches Tar des Verzeichnisses
- 14 Tage Aufbewahrung
- Bei Neustart: Backup zurückspielen oder einmalig einloggen

## HTTPS Setup (später)

- `N8N_SECURE_COOKIE=true`
- Reverse Proxy konfigurieren
- SSL-Zertifikate bereitstellen

## Troubleshooting

- Port 5678 prüfen: `lsof -i :5678`
- Volume inspizieren: `docker inspect n8n`
- API testen: `curl http://localhost:5678/rest/workflows`
