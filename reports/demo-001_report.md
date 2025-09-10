# Run-Report: demo-001

**Zeitpunkt:**
- UTC: 2025-09-04T12:00:00Z
- Europe/Zurich: 2025-09-04T14:00:00+02:00

**Trigger:**
- Endpoint: POST /agents/ingest
- Quelle: examples/ingest_sample.json

**Sequenzübersicht:**
| Schritt                | Startzeit | Dauer (s) | Ergebnis/Artefakt |
|-----------------------|-----------|-----------|-------------------|
| CEO-Agent             | 14:00:00  | 0.5       | orchestriert      |
| Whisper-Transcribe    | 14:00:01  | 8.2       | transcript_text   |
| Clipping-Markers      | 14:00:09  | 2.1       | markers[]         |
| Content-Generator     | 14:00:11  | 3.5       | content{}         |
| Notion-Writer         | 14:00:15  | 1.2       | notion_page_id    |

**Ergebnislinks:**
- Notion-Page: https://notion.so/xxxxxx (ID geschwärzt)
- Transkript: ./data/n8n/demo-001_transcript.txt

**Metriken:**
- Gesamtdauer: 15.5s
- Tokenverbrauch: 2.1k (geschätzt)
- Transkriptgröße: 12 KB
- Marker: 5

**Fehler/Warnings:**
- keine

**Systemumgebung:**
- n8n: n8nio/n8n:latest
- Traefik: traefik:v3
- Postgres: postgres:15-alpine
