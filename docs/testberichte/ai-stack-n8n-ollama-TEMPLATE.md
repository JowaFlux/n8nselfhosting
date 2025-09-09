# Testbericht – n8n + Ollama (AI Stack)

## 1. Zusammenfassung
- Datum (UTC): <!-- 2025-09-09T10:15:00Z -->
- Verantwortlich: <!-- Name -->
- Ergebnis: <!-- Erfolg/Teilweise/Fehlgeschlagen -->
- Evidence-Pfad: <!-- z.B. /data/proofs/P3-owner-auth-20250909-1015.tar.gz -->

## 2. Setup
- genutzte Datei: `docker-compose.ai_stack.yml`
- `.env` gesetzt: `N8N_BASIC_AUTH_ACTIVE`, `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`, `WEBHOOK_URL`
- Startbefehle:
```bash
docker compose -f docker-compose.ai_stack.yml up -d
docker compose -f docker-compose.ai_stack.yml ps
```

• Output docker compose ps (Anhang / Auszug):

<!-- paste -->

## 3. Autostart nach Reboot
- Reboot durchgeführt: <!-- ja/nein -->
- Status nach Reboot:
```bash
docker compose -f docker-compose.ai_stack.yml ps
```
<!-- paste -->

## 4. Verifikationen

### Ollama Host
```bash
curl -s http://localhost:11434/api/tags | jq .
```
<!-- paste JSON -->

### n8n Auth
# no auth -> expected 401/403
<!-- paste code -->

# with auth -> expected 200
<!-- paste code -->

### Container-intern n8n → ollama
```bash
docker exec -it n8n sh -lc "curl -s http://ollama:11434/api/tags"
```
<!-- paste JSON -->

## 5. Koordinator-Webhook Sanity-Run

Request:
```bash
curl -s -X POST http://localhost:5678/webhook/coordinator \
  -H 'Content-Type: application/json' \
  -u "admin:${N8N_BASIC_AUTH_PASSWORD}" \
  -d '{ "task":"dry-run", "commands":["echo hello"], "policy":{"risk_level":"low","allow_commands":["^echo\\s+hello$"]}, "evidence_expected":["logs","exit_code","duration"], "utc_started_at":"<!-- UTC -->" }' | jq .
```

Response:

<!-- paste JSON -->

## 6. Evidence
- Archiv: <!-- pfad -->
- Enthalten:
  - n8n_ps.txt
  - n8n_logs_tail.txt
  - ollama_logs_tail.txt
  - ui_noauth.code
  - ui_auth.code

## 7. Screenshots
- n8n Login-Screen (Basic-Auth)
- Ollama /api/tags JSON

## 8. Abweichungen / Risiken / Empfehlungen
- (z. B. Ports, Firewall, Passwort-Policy, Rate-Limits)

## 9. Schlussbewertung
- Status: <!-- Erfolg/Teilweise/Fehlgeschlagen -->
- Nächste Schritte: <!-- z. B. Remediation, Follow-ups -->

---

*Erstellt aus Vorlage — bitte als `docs/testberichte/ai-stack-n8n-ollama-YYYYMMDD.md` ablegen und mit UTC‑Zeitstempel ergänzen.*
