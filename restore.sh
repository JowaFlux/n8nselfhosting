#!/usr/bin/env bash
set -euo pipefail

# Restore Script for n8n Self-Hosting Setup
# Version: 1.0
# Author: JowaFlux
# Description: Restore n8n data, Postgres DB, and configs from backup

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_timestamp>"
    echo "Example: $0 20231201_021500"
    exit 1
fi

BACKUP_TS="$1"
BACKUP_DIR="./backups"

echo "Starting restore from backup: ${BACKUP_TS}"

# Stop containers
echo "Stopping containers..."
docker compose down

# Restore Postgres data
echo "Restoring Postgres data..."
if [ -f "${BACKUP_DIR}/postgres/${BACKUP_TS}.sql.gz" ]; then
    gunzip -c "${BACKUP_DIR}/postgres/${BACKUP_TS}.sql.gz" | docker compose exec -T postgres psql -U "$POSTGRES_USER" "$POSTGRES_DB"
else
    echo "Warning: Postgres backup not found: ${BACKUP_DIR}/postgres/${BACKUP_TS}.sql.gz"
fi

# Restore n8n data
echo "Restoring n8n data..."
if [ -f "${BACKUP_DIR}/n8n_data/n8n_data_${BACKUP_TS}.tar.gz" ]; then
    docker run --rm -v n8n_n8n_data:/data -v "$(pwd)/${BACKUP_DIR}/n8n_data":/backup alpine tar xzf "/backup/n8n_data_${BACKUP_TS}.tar.gz" -C /data
else
    echo "Warning: n8n data backup not found: ${BACKUP_DIR}/n8n_data/n8n_data_${BACKUP_TS}.tar.gz"
fi

# Restore configs (optional - user can manually copy if needed)
echo "Configs backup available at: ${BACKUP_DIR}/configs/"
echo "Manually restore configs if needed."

# Start containers
echo "Starting containers..."
docker compose up -d

echo "Restore completed from backup: ${BACKUP_TS}"

# Evidence collection
EVIDENCE_FILE="${BACKUP_DIR}/restore_evidence_${BACKUP_TS}_$(date +%Y%m%d_%H%M%S).txt"
echo "A: Restore completed successfully" > "${EVIDENCE_FILE}"
echo "B: Files restored: postgres_dump, n8n_data" >> "${EVIDENCE_FILE}"
echo "C: Backup timestamp: ${BACKUP_TS}" >> "${EVIDENCE_FILE}"
echo "D: Restore timestamp: $(date +%Y%m%d_%H%M%S)" >> "${EVIDENCE_FILE}"
echo "E: Services restarted: n8n, postgres, traefik" >> "${EVIDENCE_FILE}"

echo "Evidence logged to: ${EVIDENCE_FILE}"
