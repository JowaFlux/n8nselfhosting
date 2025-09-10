#!/usr/bin/env bash
set -euo pipefail
curl -s http://localhost:11434/api/chat \
 -H 'Content-Type: application/json' \
 -d '{"model":"'"${CHAT_MODEL:-llama3.1:8b-instruct-q4_0}"'","messages":[{"role":"user","content":"Sag nur: OK"}],"stream":false}' | jq -r '.message.content // .message // .'
