# n8n Agent – Ollama + Google Drive/Sheets RAG (Self‑Hosted)

**Ziel**: Clean‑Slate neu aufsetzen, n8n (Docker), Ollama (Mac nativ, später Linux‑Container), RAG via Google Drive + Google Sheets. Erster Koordinator‑Agent liefert JSON, bewertet sich (1–1000) und iteriert bis **≥950**.

## Quickstart (Mac)
1. `brew install ollama && ollama serve`
2. `ollama pull llama3.1:8b-instruct-q4_0 && ollama pull nomic-embed-text`
3. `.env` aus `.env.example` kopieren und Werte setzen
4. `docker compose -f docker-compose.mac.yml up -d`
5. n8n Owner einmalig anlegen → Google **Drive** & **Sheets** OAuth‑Credentials verbinden
6. Workflows importieren (unter `workflows/`)
7. `./scripts/test_chat.sh` und `./scripts/test_index.sh` ausführen

## Umzug auf Linux (Beelink)
- `docker compose -f docker-compose.linux.yml up -d`

## Wichtige Pfade/Backups
- n8n Daten: `./data/n8n`
- Vektorstore: `./data/knowledge.sqlite`

## Sicherheit
- Ändere **N8N_ENCRYPTION_KEY** nie nachträglich; lösche Volumes nicht → sonst Owner‑Sign‑Up erneut.
