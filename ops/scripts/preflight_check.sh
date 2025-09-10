#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$PROJECT_DIR"
echo "[1/4] Port-Check"; (lsof -i :5678 >/dev/null 2>&1 || true)
echo "[2/4] Compose-Status"; docker compose -f docker/compose.n8n.yml --env-file .env.n8n ps
echo "[3/4] Volume-Check"; docker inspect n8n | grep -A2 "/home/node/.n8n" || true
echo "[4/4] API-Probe"; curl -fsS http://localhost:5678/ >/dev/null && echo "OK" || (echo "API down" && exit 1)
