#!/usr/bin/env bash
set -euo pipefail
DB=./data/knowledge.sqlite
OUT=./evidence/REPORT.md
mkdir -p ./evidence
{
  echo "# Proof Report"
  echo
  sqlite3 -markdown "$DB" "SELECT run_id, status, score, started_at, finished_at, summary FROM runs ORDER BY started_at DESC LIMIT 20;"
  echo
  echo "## Steps (latest run)"
  RID=$(sqlite3 "$DB" "SELECT run_id FROM runs ORDER BY started_at DESC LIMIT 1;")
  sqlite3 -markdown "$DB" "SELECT name,status,duration_ms,retries,message FROM steps WHERE run_id='$RID' ORDER BY started_at;"
  echo
  echo "## Artifacts (latest run)"
  sqlite3 -markdown "$DB" "SELECT path,size_bytes,mime FROM artifacts WHERE run_id='$RID' ORDER BY path;"
} > "$OUT"
echo "Report → $OUT"
