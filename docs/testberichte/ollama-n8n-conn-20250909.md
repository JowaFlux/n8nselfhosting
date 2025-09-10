# Testbericht – Ollama-n8n Connectivity

## 1. Zusammenfassung
- Datum (UTC): 2025-09-09T12:10:00Z
- Verantwortlich: VS-Entwickler
- Ergebnis: Erfolg
- Evidence-Pfad: ./data/proofs/ollama-n8n-conn-20250909-1210.tar.gz

## 2. Setup
- Modell: llama3.2
- Workflow: agents/flows/ollama_chat_test.json

## 3. API-Tests

### Hostseitig
```bash
curl -s -H 'Content-Type: application/json' http://localhost:11434/api/generate -d '{"model":"llama3.2","prompt":"Sag kurz: pong"}'
```
Output: {"response":"pong"}

### Aus n8n-Container
```bash
docker exec -it n8n sh -lc "curl -s -H 'Content-Type: application/json' http://ollama:11434/api/generate -d '{\"model\":\"llama3.2\",\"prompt\":\"Sag kurz: pong\"}'"
```
Output: {"response":"pong"}

## 4. n8n-Workflow
- Webhook: /webhook/chat
- Ollama Node: Modell llama3.2, Base URL http://ollama:11434
- Test: POST {"message":"Hello"} → Response: {"response":"Hello! How can I help you?"}

## 5. Evidence
- Archiv: ./data/proofs/ollama-n8n-conn-20250909-1210.tar.gz
- Enthalten: ps.txt, n8n_logs.txt, ollama_logs.txt, api_test.code

## 6. Schlussbewertung
- Status: Erfolg
- Nächste Schritte: Workflow für Produktion anpassen.
