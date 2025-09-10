#!/usr/bin/env bash
set -euo pipefail
read -p "Alle Container/Volumes entfernen? (yes/NO) " yn
if [[ "$yn" == "yes" ]]; then
  docker compose -f docker-compose.mac.yml down -v || true
  docker compose -f docker-compose.linux.yml down -v || true
  rm -rf ./data/n8n ./data/knowledge.sqlite
  echo "Bereinigt."
else
  echo "Abgebrochen."
fi
