#!/bin/bash
# n8n Backup Script
# Sichert /home/node/.n8n in ein tar.gz Archiv
# Aufbewahrung: 14 Tage

BACKUP_DIR="/home/node"
SOURCE_DIR="$BACKUP_DIR/.n8n"
DATE=$(date +%F)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$DATE.tgz"

# Backup erstellen
docker exec n8n tar czf "$BACKUP_FILE" -C "$BACKUP_DIR" .n8n

# Alte Backups löschen (älter als 14 Tage)
find "$BACKUP_DIR" -name "n8n_backup_*.tgz" -mtime +14 -delete

echo "Backup erstellt: $BACKUP_FILE"
