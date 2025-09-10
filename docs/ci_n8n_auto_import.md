# CI – n8n Auto-Import

## Secrets (Repo → Settings → Secrets and variables → Actions)

- N8N_BASE_URL  (z.B. `https://n8n.example.com`)
- N8N_API_KEY   (Server-API-Key mit Workflow-Rechten)
- Optional: N8N_API_KEY_LOCAL für self-hosted Runner

## Trigger

- push auf main (Änderungen in workflows/*.json)
- schedule täglich 01:15 UTC
- workflow_dispatch (manuell)

## Tests

1) workflow_dispatch → läuft und zeigt JSON Summary.
2) Commit unter workflows/*.json → Action feuert, Workflows importiert/updated.
3) Fehlerfälle: 401/403 (Key/ACL), ENOTFOUND (URL/Tunnel/VPN).
