# n8n Health & Drift Report (ohne GitHub)

## Was der Workflow macht

- Täglicher Cron (02:30 Europe/Zurich) ruft:
  - `/rest/workflows`
  - `/rest/executions-current`
  - `/rest/executions?limit=25`
- Erstellt JSON-Report mit `total`, `running`, `recent`, `added`, `removed`, `updated`.
- Speichert den aktuellen Stand (Snapshot) in Workflow Static Data → Vergleich beim nächsten Lauf.
- Optional: Slack/Telegram-Benachrichtigung.

## Setup

1. **API-Key bereitstellen**
   - Container-ENV: `N8N_API_KEY=<dein_key>` **oder** HTTP-Request-Credential anlegen und im Workflow verwenden.
2. **Import**
   - `n8n/health_drift_report.json` importieren.
3. **Benachrichtigungen (optional)**
   - Slack: `SLACK_WEBHOOK_URL` Umgebungsvariable setzen und Node „Notify Slack" aktivieren.
   - Telegram: `TG_BOT_TOKEN`, `TG_CHAT_ID` setzen und Node „Notify Telegram" aktivieren.
4. **Test**
   - Workflow manuell starten (Manual Trigger).
   - Im zweiten Lauf (nach Änderung eines Workflows) sollten `updated/added/removed` > 0 sein.

## Interpretation

- **added**: neue Workflows seit letztem Snapshot
- **removed**: Workflows, die es vorher gab, jetzt nicht mehr
- **updated**: Name/aktiv-Status/Version/updatedAt hat sich geändert
- **running/recent**: aktuelle/letzte Executions als Betriebsindikator

## Pflege

- Cron-Zeit im Cron-Node anpassen.
- Für langlebige Sessions: `N8N_USER_MANAGEMENT_JWT_DURATION_HOURS` in Docker-Compose.

## Fehlerbehebung

- 401/403: API-Key prüfen / Credential richtig binden.
- ENOTFOUND/ECONNREFUSED: `N8N_BASE_URL` korrigieren (`http://localhost:5678`).
- Kein Drift: Erwartbar, wenn keine Änderungen.
