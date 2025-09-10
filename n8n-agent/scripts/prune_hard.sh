#!/usr/bin/env bash
set -euo pipefail
read -p "Hard prune knowledge.sqlite (DELETE ALL)? (yes/NO) " yn
if [[ "$yn" == "yes" ]]; then
  sqlite3 ./data/knowledge.sqlite "DELETE FROM chunks; DELETE FROM documents; VACUUM;"
  echo "DB cleared."
else
  echo "Abgebrochen."
fi
