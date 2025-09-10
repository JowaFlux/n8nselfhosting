#!/usr/bin/env bash
set -euo pipefail

# Enhanced Backup Script for n8n Self-Hosting Setup
# Version: 1.1
# Author: JowaFlux
# Description: Automated backup of n8n data, Postgres DB, configs, and evidence collection

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="n8n_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}/postgres"
mkdir -p "${BACKUP_DIR}/n8n_data"
mkdir -p "${BACKUP_DIR}/configs"

echo "Starting backup: ${BACKUP_NAME}"

# Backup Postgres data (existing functionality)
echo "Backing up Postgres data..."
docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" \
  | gzip > "./backups/postgres/${TIMESTAMP}.sql.gz"

# Backup n8n data volume
echo "Backing up n8n data..."
docker run --rm -v n8n_n8n_data:/data -v "$(pwd)/${BACKUP_DIR}/n8n_data":/backup alpine tar czf "/backup/n8n_data_${TIMESTAMP}.tar.gz" -C /data .

# Backup configs
echo "Backing up configs..."
cp docker-compose.yml "${BACKUP_DIR}/configs/docker-compose_${TIMESTAMP}.yml"
cp .env "${BACKUP_DIR}/configs/.env_${TIMESTAMP}" 2>/dev/null || echo "Warning: .env not found"
cp -r agents/ "${BACKUP_DIR}/configs/agents_${TIMESTAMP}/" 2>/dev/null || echo "Warning: agents/ not found"
cp -r docs/ "${BACKUP_DIR}/configs/docs_${TIMESTAMP}/" 2>/dev/null || echo "Warning: docs/ not found"

# Rotate old backups (keep last 7)
echo "Rotating old backups..."
find ./backups -type f -name "*.sql.gz" -mtime +7 -delete 2>/dev/null || true
find ./backups -type f -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true
find ./backups -type f -name "*_${TIMESTAMP}*" -mtime +7 -delete 2>/dev/null || true

echo "Backup completed: ${BACKUP_NAME}"

# Evidence collection
EVIDENCE_FILE="${BACKUP_DIR}/backup_evidence_${TIMESTAMP}.txt"
echo "A: Backup completed successfully" > "${EVIDENCE_FILE}"
echo "B: Files backed up: postgres_dump.sql.gz, n8n_data.tar.gz, configs" >> "${EVIDENCE_FILE}"
echo "C: Backup sizes:" >> "${EVIDENCE_FILE}"
du -sh ./backups/postgres/${TIMESTAMP}.sql.gz >> "${EVIDENCE_FILE}" 2>/dev/null || echo "  Postgres: N/A" >> "${EVIDENCE_FILE}"
du -sh ./backups/n8n_data/n8n_data_${TIMESTAMP}.tar.gz >> "${EVIDENCE_FILE}" 2>/dev/null || echo "  n8n_data: N/A" >> "${EVIDENCE_FILE}"
echo "D: Timestamp: ${TIMESTAMP}" >> "${EVIDENCE_FILE}"
echo "E: Next scheduled: $(date -v+1d +"%Y-%m-%d 02:15" 2>/dev/null || date -d tomorrow +"%Y-%m-%d 02:15")" >> "${EVIDENCE_FILE}"

echo "Evidence logged to: ${EVIDENCE_FILE}"
