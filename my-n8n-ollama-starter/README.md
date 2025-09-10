# n8n × Ollama – VS Code Starter

## Quickstart

1. VS Code öffnen (Ordner laden).
2. Tasks ausführen:
   - `Stack: Up`
   - `Ollama: Pull Model llama3:8b`
   - `n8n: Open UI` (Login: admin/admin oder in .env ändern)
3. In n8n: **Workflows → Import from File** → `n8n-workflows/ollama-chat.json`
4. Tests:
   - Datei `tests/ollama-test.http` öffnen → **Send Request**
   - Datei `tests/n8n-webhook-test.http` öffnen → **Send Request**

## URLs

- Ollama API: `http://localhost:11434`
- n8n UI: `http://localhost:5678`
- Webhook: `POST http://localhost:5678/webhook/ollama-chat`

## Hinweise

- Compose speichert Daten in `ollama_data` (Modelle) und `n8n_data` (Settings).
- Anpassung der Zugangsdaten über `.env`.
