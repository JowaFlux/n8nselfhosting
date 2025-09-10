# n8n Rollback Guide

## Backup wiederherstellen

1. **Container stoppen:**

   ```bash
   docker compose -f docker/compose.n8n.yml down
   ```

2. **Backup extrahieren:**

   ```bash
   # Liste verfügbare Backups
   ls -la /home/node/n8n_backup_*.tgz

   # Extrahiere das gewünschte Backup
   docker run --rm -v /home/node:/data alpine tar xzf /data/n8n_backup_2025-09-09.tgz -C /data
   ```

3. **Container neu starten:**

   ```bash
   docker compose -f docker/compose.n8n.yml up -d
   ```

## Notfall-Rollback (ohne Backup)

1. **Volume löschen und neu erstellen:**

   ```bash
   docker compose -f docker/compose.n8n.yml down
   docker volume rm n8nselfhosting_n8n_data
   docker compose -f docker/compose.n8n.yml up -d
   ```

2. **Workflows neu importieren:**

   ```bash
   node tools/overview/auto-import.js
   ```

## Präventive Maßnahmen

- Tägliche Backups um 02:00 Uhr
- Aufbewahrung: 14 Tage
- Regelmäßige Tests der Backup-Integrität
