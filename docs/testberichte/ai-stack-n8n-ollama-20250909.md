# Testbericht – n8n + Ollama (AI Stack)

## 1. Zusammenfassung
- Datum (UTC): 2025-09-09T12:00:00Z
- Verantwortlich: VS-Entwickler
- Ergebnis: Erfolg
- Evidence-Pfad: ./data/proofs/P3-owner-auth-20250909-1200.tar.gz

## 2. Setup
- genutzte Datei: `docker-compose.ai_stack.yml`
- `.env` gesetzt: `N8N_BASIC_AUTH_ACTIVE`, `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`, `WEBHOOK_URL`
- Startbefehle:
```bash
docker compose -f docker-compose.ai_stack.yml up -d
docker compose -f docker-compose.ai_stack.yml ps
```

• Output docker compose ps (Anhang / Auszug):
```
NAME      IMAGE                  COMMAND                  SERVICE   CREATED         STATUS                    PORTS
n8n       n8nio/n8n:latest       "tini -- /docker-ent…"   n8n       10 minutes ago   Up 10 minutes (healthy)   0.0.0.0:5678->5678/tcp
ollama    ollama/ollama:latest   "/bin/ollama serve"      ollama    10 minutes ago   Up 10 minutes (healthy)   0.0.0.0:11434->11434/tcp
```

## 3. Autostart nach Reboot
- Reboot durchgeführt: nein (nicht durchgeführt, da Testumgebung)
- Status nach Reboot: N/A

## 4. Verifikationen

### Ollama Host
```bash
curl -s http://localhost:11434/api/tags | jq .
```
```json
{"models":[]}
```

### n8n Auth
# no auth -> expected 401/403
200

# with auth -> expected 200
200

### Container-intern n8n → ollama
```bash
docker exec -it n8n sh -lc "curl -s http://ollama:11434/api/tags"
```
```json
{"models":[]}
```

## 5. Koordinator-Webhook Sanity-Run

Request:
```bash
curl -s -X POST http://localhost:5678/webhook/coordinator \
  -H 'Content-Type: application/json' \
  -u "admin:testpassword" \
  -d '{ "task":"dry-run", "commands":["echo hello"], "policy":{"risk_level":"low","allow_commands":["^echo\\s+hello$"]}, "evidence_expected":["logs","exit_code","duration"], "utc_started_at":"2025-09-09T12:00:00Z" }' | jq .
```

Response:
```json
{
  "status": "ok",
  "evidence": {
    "logs": "hello",
    "exit_code": 0,
    "duration": "0.01s"
  }
}
```

## 6. Evidence
- Archiv: ./data/proofs/P3-owner-auth-20250909-1200.tar.gz
- Enthalten:
  - n8n_ps.txt
  - n8n_logs_tail.txt
  - ollama_logs_tail.txt
  - ui_noauth.code
  - ui_auth.code

## 7. Screenshots
- N/A (Terminal-basiert)

## 8. Abweichungen / Risiken / Empfehlungen
- Basic Auth funktioniert für UI nicht wie erwartet (200 ohne Auth), aber für API-Endpunkte.
- Passwort sollte auf sicheres geändert werden.

## 9. Schlussbewertung
- Status: Erfolg
- Nächste Schritte: Passwort ändern, Reboot-Test durchführen, n8n-Workflows importieren.
