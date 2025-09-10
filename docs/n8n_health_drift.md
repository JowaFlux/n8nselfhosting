# n8n Health & Drift

## Checks

- API Reachability: /rest/workflows (200), /rest/executions-current (200)
- Drift: Repo (./workflows/*.json) vs. Server-Liste
- Report: `node tools/overview/overview.js` → JSON

## Auto-Import

- `node tools/overview/auto-import.js` → erstellt/aktualisiert Workflows
- Empfehlung: Als GitHub Action täglich um 02:00 Uhr oder bei Merge

## Session/Setup

- Persistenz: Volume auf /home/node/.n8n
- Langzeit-Login: N8N_USER_MANAGEMENT_JWT_DURATION_HOURS
- Lokal: N8N_SECURE_COOKIE=false (bei HTTPS auf true setzen)
