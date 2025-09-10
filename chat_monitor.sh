#!/bin/bash

# Chat Sanity Monitor
# Sammelt Sanity-Test Ergebnisse und generiert Reports

set -e

MONITOR_DIR="./monitoring"
mkdir -p "$MONITOR_DIR"

echo "=== Chat Sanity Monitor ==="
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Test Chat direkt
echo -e "\n1. Direkter Chat-Test:"
CHAT_RESULT=$(curl -s -X POST "https://n8n.example.com/webhook/chat" \
  -H 'Content-Type: application/json' \
  -u "admin:CHANGE_ME_32CHARS!" \
  -d '{"message":"Monitor-Test: Status?"}' \
  --max-time 30 2>/dev/null || echo '{"error": "connection_failed"}')

echo "$CHAT_RESULT" | jq . 2>/dev/null || echo "$CHAT_RESULT"

# Container Status
echo -e "\n2. Container Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Logs der letzten 10 Minuten
echo -e "\n3. Letzte n8n Logs (10 Min):"
docker logs --since "10m" n8n 2>/dev/null | tail -20 || echo "Logs nicht verfügbar"

# Ollama Health Check
echo -e "\n4. Ollama Status:"
docker exec n8n curl -s http://ollama:11434/api/tags 2>/dev/null | jq '.models | length' 2>/dev/null || echo "Ollama nicht erreichbar"

# Report generieren
REPORT_FILE="$MONITOR_DIR/sanity_report_$(date -u +%Y%m%d_%H%M).txt"
cat > "$REPORT_FILE" << EOF
Chat Sanity Report
==================
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Chat Test Result:
$CHAT_RESULT

Container Status:
$(docker compose ps --format "{{.Name}}: {{.Status}}")

Ollama Models:
$(docker exec n8n curl -s http://ollama:11434/api/tags 2>/dev/null | jq '.models[].name' 2>/dev/null || echo "N/A")

Evidence: A=$(echo "$CHAT_RESULT" | jq -r '.response // empty' | wc -c) chars response
Evidence: B=Container status captured
Evidence: C=Ollama connectivity checked
Evidence: D=Report generated
Evidence: E=Next check in 5 minutes
EOF

echo -e "\n✅ Report erstellt: $REPORT_FILE"
echo "📊 Nächster Check: $(date -v+5M +%H:%M:%S 2>/dev/null || date -d '+5 minutes' +%H:%M:%S)"
