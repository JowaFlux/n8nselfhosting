#!/bin/bash
TS=$(date -u +%Y%m%d-%H%M)
EVIDENCE_DIR="./data/proofs/health-$TS"
mkdir -p "$EVIDENCE_DIR"

# Containerstatus
docker compose -f docker-compose.yml ps > "$EVIDENCE_DIR/compose_ps.txt"

# Logs
docker logs --tail=100 n8n > "$EVIDENCE_DIR/n8n_logs.txt"
docker logs --tail=100 traefik > "$EVIDENCE_DIR/traefik_logs.txt"

# Chat-Test
curl -s -u "admin:testpassword" \
  -H 'Content-Type: application/json' \
  -d '{"message":"Health-Check"}' \
  "https://n8n.example.com/webhook/chat" > "$EVIDENCE_DIR/chat_response.json"

# Status check and alert
STATUS=$(jq -r '.response? // empty' "$EVIDENCE_DIR/chat_response.json" | wc -c | awk '{print ($1>0)?"ok":"fail"}')
if [ "$STATUS" != "ok" ]; then
  curl -s -X POST "$COMET_FUNKMELDUNG_URL" \
    -H "Authorization: Bearer $COMET_TOKEN" -H "Content-Type: application/json" \
    -d "{\"action\":\"health_fail\",\"ts_utc\":\"$(date -u +%FT%TZ)\",\"evidence\":\"$EVIDENCE_DIR.tar.gz\"}" >/dev/null
fi

# Ergebnis packen
tar -czf "$EVIDENCE_DIR.tar.gz" -C "$(dirname $EVIDENCE_DIR)" "$(basename $EVIDENCE_DIR)"
echo "Evidence-Pack: $EVIDENCE_DIR.tar.gz"
