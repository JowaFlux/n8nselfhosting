#!/usr/bin/env bash
set -euo pipefail

# Load credentials from .env
ENV_PATH="/opt/n8n/.env"
N8N_USER=$(grep '^N8N_BASIC_AUTH_USER=' "$ENV_PATH" | cut -d'=' -f2)
N8N_PASS=$(grep '^N8N_BASIC_AUTH_PASSWORD=' "$ENV_PATH" | cut -d'=' -f2)
N8N_URL=$(grep '^WEBHOOK_URL=' "$ENV_PATH" | cut -d'=' -f2)
API_URL="${N8N_URL%/}/rest/workflows"

LOG="reports/dev_import_test.log"
COUNT=0
UPDATED=0
CREATED=0
ERRORS=0

done

for FLOW in agents/flows/*.json; do
  NAME=$(jq -r '.name' "$FLOW")
  ID=$(jq -r '.id // empty' "$FLOW")
  if [ -z "$NAME" ]; then
    echo "[WARN] $FLOW: No name found, skipping." | tee -a "$LOG"
    ERRORS=$((ERRORS+1))
    continue
  fi
  START=$(date +%s)
  if [ -n "$ID" ]; then
    # Try PATCH (update)
    RESP=$(curl -s -w "%{http_code}" -u "$N8N_USER:$N8N_PASS" -X PATCH "$API_URL/$ID" -H 'Content-Type: application/json' -d @"$FLOW")
    CODE="${RESP: -3}"
    BODY="${RESP::-3}"
    END=$(date +%s)
    DURATION=$((END-START))
    if echo "$BODY" | grep -q '"id"'; then
      echo "[INFO] Updated flow: $NAME ($ID) | Status: $CODE | Duration: ${DURATION}s" | tee -a "$LOG"
      UPDATED=$((UPDATED+1))
    else
      echo "[ERROR] Failed to update $NAME ($ID) | Status: $CODE | Duration: ${DURATION}s" | tee -a "$LOG"
      ERRORS=$((ERRORS+1))
    fi
  else
    # Try POST (create)
    RESP=$(curl -s -w "%{http_code}" -u "$N8N_USER:$N8N_PASS" -X POST "$API_URL" -H 'Content-Type: application/json' -d @"$FLOW")
    CODE="${RESP: -3}"
    BODY="${RESP::-3}"
    END=$(date +%s)
    DURATION=$((END-START))
    if echo "$BODY" | grep -q '"id"'; then
      echo "[INFO] Created flow: $NAME | Status: $CODE | Duration: ${DURATION}s" | tee -a "$LOG"
      CREATED=$((CREATED+1))
    else
      echo "[ERROR] Failed to create $NAME | Status: $CODE | Duration: ${DURATION}s" | tee -a "$LOG"
      ERRORS=$((ERRORS+1))
    fi
  fi
  COUNT=$((COUNT+1))


TS=$(date '+%Y-%m-%d %H:%M')
echo "[$TS] Imported $COUNT flows into n8n-dev ($UPDATED updated, $CREATED new). $ERRORS errors." | tee -a "$LOG"
if [ "$ERRORS" -eq 0 ]; then
  echo "All flows imported successfully." | tee -a "$LOG"
  exit 0
else
  exit 1
fi
