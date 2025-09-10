#!/usr/bin/env bash
set -euo pipefail

# Audit Aggregate: Combine proof data with git information
echo "=== Audit Aggregation ==="

DB=./data/knowledge.sqlite
OUT=./evidence/AUDIT_LOG.md
mkdir -p ./evidence

# Get latest run info
LATEST_RUN=$(sqlite3 "$DB" "SELECT run_id FROM runs ORDER BY started_at DESC LIMIT 1;" 2>/dev/null || echo "")

{
    echo "# Audit Log: Proof Collection + Git History"
    echo
    echo "## System Overview"
    echo "- **Generated:** $(date)"
    echo "- **Database:** $DB"
    echo "- **Evidence Directory:** ./evidence/"
    echo "- **Git Repository:** $(git remote get-url origin 2>/dev/null || echo 'Not configured')"
    echo
    echo "## Latest Run Summary"
    if [[ -n "$LATEST_RUN" ]]; then
        sqlite3 -markdown "$DB" "SELECT run_id, status, score, started_at, finished_at, summary FROM runs WHERE run_id='$LATEST_RUN';"
        echo
        echo "### Steps in Latest Run"
        sqlite3 -markdown "$DB" "SELECT name, status, duration_ms, retries, message FROM steps WHERE run_id='$LATEST_RUN' ORDER BY started_at;"
        echo
        echo "### Artifacts in Latest Run"
        sqlite3 -markdown "$DB" "SELECT path, mime, size_bytes FROM artifacts WHERE run_id='$LATEST_RUN' ORDER BY path;"
    else
        echo "No runs recorded yet."
    fi
    echo
    echo "## Git Commit History (Last 5)"
    git log --oneline -5 2>/dev/null || echo "No git history available"
    echo
    echo "## Database Statistics"
    echo "- **Documents:** $(sqlite3 "$DB" "SELECT COUNT(*) FROM documents;" 2>/dev/null || echo 'N/A')"
    echo "- **Chunks:** $(sqlite3 "$DB" "SELECT COUNT(*) FROM chunks;" 2>/dev/null || echo 'N/A')"
    echo "- **Runs:** $(sqlite3 "$DB" "SELECT COUNT(*) FROM runs;" 2>/dev/null || echo 'N/A')"
    echo "- **Steps:** $(sqlite3 "$DB" "SELECT COUNT(*) FROM steps;" 2>/dev/null || echo 'N/A')"
    echo "- **Artifacts:** $(sqlite3 "$DB" "SELECT COUNT(*) FROM artifacts;" 2>/dev/null || echo 'N/A')"
    echo
    echo "## Evidence Files"
    if [[ -d ./evidence ]]; then
        find ./evidence -type f -not -name '.*' | sort || echo "No evidence files found"
    else
        echo "Evidence directory not found"
    fi
    echo
    echo "*This audit log combines automated proof collection with version control history for complete traceability.*"
} > "$OUT"

echo "Audit log saved to $OUT"
