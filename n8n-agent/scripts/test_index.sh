#!/usr/bin/env bash
set -euo pipefail
# Prüft, ob SQLite existiert, legt Schema an
sqlite3 ./data/knowledge.sqlite < ./scripts/schema.sqlite.sql
printf "OK: knowledge.sqlite vorbereitet\n"
