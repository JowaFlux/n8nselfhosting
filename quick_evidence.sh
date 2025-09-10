#!/bin/bash

# Quick-Evidence Script für P3 Chat-Stability Tests
# Version: 1.0
# Author: JowaFlux

set -e

EVIDENCE_DIR="./evidence"
mkdir -p "$EVIDENCE_DIR"

TIMESTAMP=$(date -u +%Y%m%d-%H%M)
echo "Collecting evidence: $TIMESTAMP"

# Load environment
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Container status
docker compose ps > "$EVIDENCE_DIR/compose_ps.txt"

# Recent logs
docker logs --tail=150 n8n > "$EVIDENCE_DIR/n8n_tail.txt" 2>/dev/null || echo "n8n logs unavailable" > "$EVIDENCE_DIR/n8n_tail.txt"

# Timestamp
date -u +%FT%TZ > "$EVIDENCE_DIR/ts_utc.txt"

# Chat test
echo "Testing chat webhook..."
CHAT_RESPONSE=$(curl -s -X POST "https://$N8N_DOMAIN/webhook/chat" \
  -H 'Content-Type: application/json' \
  -u "admin:$N8N_BASIC_AUTH_PASSWORD" \
  -d '{"message":"Warmstart-Test"}' \
  --max-time 60 2>/dev/null || echo '{"error": "timeout or connection failed"}')

echo "$CHAT_RESPONSE" > "$EVIDENCE_DIR/chat_response.json"

# Create archive
ARCHIVE_NAME="P3-chat-stability-$TIMESTAMP.tar.gz"
tar -czf "./data/proofs/$ARCHIVE_NAME" "$EVIDENCE_DIR" 2>/dev/null || tar -czf "$ARCHIVE_NAME" "$EVIDENCE_DIR"

echo "Evidence collected: ./data/proofs/$ARCHIVE_NAME"
echo "A: Container status captured"
echo "B: Recent logs archived"
echo "C: Chat response tested"
echo "D: Timestamp: $TIMESTAMP"
echo "E: Archive created successfully"
