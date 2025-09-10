# n8n Selfhosting – Setup & Betrieb

## Architektur

```mermaid
graph TD
    subgraph Traefik
        traefik[Traefik (SSL/TLS, Dashboard)]
    end
    subgraph n8n
        n8n[n8n]
    end
    subgraph Postgres
        db[(Postgres)]
    end
    traefik -- HTTPS 443 --> n8n
    traefik -- Dashboard HTTPS 443 --> traefik
    n8n -- DB --> db
    n8n -- Volumes --> data_n8n[(./data/n8n)]
    db -- Volumes --> data_db[(./data/postgres)]
    traefik -- Certs --> letsencrypt[(./data/letsencrypt)]
    github[GitHub Actions] -- CI/CD --> traefik
    github -- CI/CD --> n8n
    github -- CI/CD --> db
```

## Start/Stop

```sh
docker compose up -d
docker compose down
```

## Logs & Health

```sh
docker compose ps
docker compose logs traefik
docker compose logs n8n
docker compose logs postgres
```

Healthcheck n8n:
```sh
curl -I https://$N8N_DOMAIN/healthz
```

## Chat Stability & Testing

### Smoke Test

```sh
curl -s -X POST https://$N8N_DOMAIN/webhook/chat \
  -H 'Content-Type: application/json' \
  -u "admin:$N8N_BASIC_AUTH_PASSWORD" \
  -d '{"message":"Sag kurz: ping"}' | jq .
```

### Preflight & Warm-Up

Import: `agents/flows/preflight_warmup_ollama.json`

- Lädt llama3.2 Modell in RAM
- Verhindert Kaltstart-Timeouts

### Stabilized Chat Workflow

Import: `agents/flows/ollama_chat_test.json` (v3.0)

- HTTP-Fallback zu Ollama API
- Robuster Response-Mapper v2
- Timeout: 120s, Retry: 3x
- Garantierte `{response: "..."}` Ausgabe

**Hotfix-Workflow (sofort einsatzbereit):**
Import: `agents/flows/koordinator_chat_hotfix.json`

- Direkter HTTP→Ollama Call
- Kein Agent-Node, kein Streaming
- deepFindText() Response-Mapper
- Garantierte Antwort

**Test-Frage:** "Was ist die Hauptstadt der Schweiz?"
**Erwartete Antwort:** Bern (oder Bundesstadt Bern)

### Quick Evidence Collection

```sh
./quick_evidence.sh
```

- Sammelt Container-Status, Logs, Chat-Response
- Erstellt P3-Archive in `./data/proofs/`

### Continuous Monitoring

**Sanity Test Workflow:**

Import: `agents/flows/sanity_test_chat_monitoring.json`

- Testet Chat alle 5 Minuten automatisch
- Validiert Response-Format
- Sendet Alerts bei Fehlern

**Chat Monitor Script:**

```sh
./chat_monitor.sh
```

- Manuell ausführbar für sofortige Checks
- Generiert detaillierte Reports in `./monitoring/`
- Cron-Job: Alle 5 Minuten automatisch

## Security & Maintenance

### Secret Rotation

```sh
./rotate_secrets.sh
```

- Generiert neue 32-Zeichen Passwörter
- Aktualisiert `.env` automatisch
- Erstellt Backups vor Rotation
- Empfohlen: Alle 90 Tage

### Evidence Retention

```sh
./evidence_retention.sh
```

- Löscht P3-Archive älter als 30 Tage
- Optimiert Speicherplatz
- Cron-Job: Täglich 02:00
- Evidence-Logging für Audits

### Alert System

Import: `agents/flows/chat_monitor_alert_system.json`

- Webhook-Alerts bei Monitoring-Fehlern
- Slack/Teams kompatibel
- Structured JSON Payloads
- Evidence-Paths inklusive

## Backup & Restore

### Backup

```sh
./backup.sh
```

- Täglich 02:15 via Cron
- Sichert: Postgres DB, n8n Data Volume, Configs
- Rotation: 7 Tage Aufbewahrung
- Evidence: Automatisch generiert in `./backups/backup_evidence_TIMESTAMP.txt`

### Restore

```sh
./restore.sh YYYYMMDD_HHMMSS
```

- Stoppt Container, restored Daten, startet Container
- Beispiel: `./restore.sh 20231201_021500`
- Evidence: Automatisch generiert in `./backups/restore_evidence_TIMESTAMP.txt`

## CI/CD Deploy

Push auf main startet automatisches Deploy:

- git pull
- docker compose pull
- docker compose up -d --remove-orphans

## Hinweise

- Logrotation ist aktiv (max 10MB, 3 Files pro Service)
- Backups werden täglich erstellt und 14 Tage aufbewahrt
- Traefik-Dashboard ist per Basic Auth und optional IP-Whitelist geschützt
- SSL/TLS via Let's Encrypt
- Volumes: ./data/n8n, ./data/postgres, ./data/letsencrypt

## Ports & Domains

- **n8n**: `https://n8n.example.com` (intern 5678)
- **Traefik Dashboard**: `https://traefik.example.com`
- **Ollama**: 11434 (wenn ai_stack verwendet)

## Workflows

- Import aus `agents/flows/`
- Versionssuffix: z.B. `ollama_chat_test_v1.1.json`

## VS Code Starter Kit

Für ein schnelles Setup: Kopiere den Ordner `my-n8n-ollama-starter/` in einen separaten VS Code Workspace.

Das Starter-Kit enthält:

- Vollständiges Docker-Setup (n8n + Ollama)
- VS Code Tasks für automatisierte Einrichtung
- REST-Client Tests (.http Dateien)
- Minimaler Chat-Workflow
- Automatischer Workflow-Import

**Schnellstart:**

1. Ordner in VS Code öffnen
2. Task "Everything: Full Setup & Test" ausführen
3. Fertig! 🎯

---

Erledigt – @VS Entwickler
