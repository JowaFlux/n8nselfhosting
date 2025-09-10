#!/bin/bash

# Evidence Archive Retention Script
# Löscht alte P3-Archive nach 30 Tagen

set -e

EVIDENCE_DIR="./data/proofs"
RETENTION_DAYS=30

echo "=== Evidence Archive Retention ==="
echo "Retention: ${RETENTION_DAYS} days"
echo "Directory: ${EVIDENCE_DIR}"

if [ ! -d "$EVIDENCE_DIR" ]; then
    echo "Evidence directory does not exist: $EVIDENCE_DIR"
    exit 0
fi

# Zähle Dateien vor Cleanup
BEFORE_COUNT=$(find "$EVIDENCE_DIR" -type f -name "*.tar.gz" | wc -l)
echo "Files before cleanup: $BEFORE_COUNT"

# Lösche alte Archive
DELETED_COUNT=$(find "$EVIDENCE_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -print -delete | wc -l)
echo "Files deleted: $DELETED_COUNT"

# Zähle Dateien nach Cleanup
AFTER_COUNT=$(find "$EVIDENCE_DIR" -type f -name "*.tar.gz" | wc -l)
echo "Files after cleanup: $AFTER_COUNT"

# Berechne Speicherplatz
SPACE_SAVED=$(find "$EVIDENCE_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1)
echo "Space saved: ${SPACE_SAVED:-0}"

# Evidence generieren
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
EVIDENCE_FILE="./data/proofs/retention_evidence_${TIMESTAMP}.txt"
cat > "$EVIDENCE_FILE" << EOF
Evidence Archive Retention Report
=================================
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Retention Days: $RETENTION_DAYS
Files Before: $BEFORE_COUNT
Files Deleted: $DELETED_COUNT
Files After: $AFTER_COUNT
Space Saved: ${SPACE_SAVED:-0}

A: Retention policy applied successfully
B: Old archives cleaned up automatically
C: Storage space optimized
D: Evidence logged for audit trail
E: Next cleanup: $(date -v+1d +%Y-%m-%d 2>/dev/null || date -d '+1 day' +%Y-%m-%d)
EOF

echo "Evidence logged: $EVIDENCE_FILE"

# Cron-Job für tägliche Ausführung hinzufügen
if ! crontab -l 2>/dev/null | grep -q "evidence_retention.sh"; then
    echo "Adding daily cron job for evidence retention..."
    (crontab -l 2>/dev/null; echo "0 2 * * * /Users/macbook/Downloads/n8nselfhosting/evidence_retention.sh >> /Users/macbook/Downloads/n8nselfhosting/logs/evidence_retention.log 2>&1") | crontab -
    echo "✅ Cron job added (daily at 02:00)"
else
    echo "ℹ️  Cron job already exists"
fi
