#!/bin/bash

# Secret Rotation Script
# Generiert neue sichere Passwörter und aktualisiert .env

set -e

ENV_FILE=".env"
BACKUP_DIR="./backups/secrets"

mkdir -p "$BACKUP_DIR"

echo "=== Secret Rotation ==="

# Backup aktuelle .env
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/.env_backup_$TIMESTAMP"
cp "$ENV_FILE" "$BACKUP_FILE"
echo "✅ Backup created: $BACKUP_FILE"

# Generiere neue Passwörter
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

NEW_N8N_PASSWORD=$(generate_password)
NEW_POSTGRES_PASSWORD=$(generate_password)
NEW_TRAEFIK_USERS=$(echo "admin:$(openssl passwd -apr1 $(generate_password))")

echo "🔄 Rotating secrets..."

# Aktualisiere .env (nur die Platzhalter-Werte)
sed -i.bak "s/N8N_BASIC_AUTH_PASSWORD=.*/N8N_BASIC_AUTH_PASSWORD=$NEW_N8N_PASSWORD/" "$ENV_FILE"
sed -i.bak "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$NEW_POSTGRES_PASSWORD/" "$ENV_FILE"
sed -i.bak "s/TRAEFIK_DASHBOARD_USERS=.*/TRAEFIK_DASHBOARD_USERS=$NEW_TRAEFIK_USERS/" "$ENV_FILE"

echo "✅ Secrets rotated successfully"
echo ""
echo "📋 New Credentials:"
echo "N8N Basic Auth Password: $NEW_N8N_PASSWORD"
echo "PostgreSQL Password: $NEW_POSTGRES_PASSWORD"
echo "Traefik Dashboard Users: admin (password rotated)"
echo ""
echo "⚠️  IMPORTANT: Update your password manager and notify team members!"
echo "🔄 Restart services: docker compose down && docker compose up -d"
echo ""

# Evidence generieren
EVIDENCE_FILE="./data/proofs/secret_rotation_${TIMESTAMP}.txt"
cat > "$EVIDENCE_FILE" << EOF
Secret Rotation Evidence
=======================
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Backup File: $BACKUP_FILE

A: Secrets rotated successfully
B: Backup created before rotation
C: Strong passwords generated (32 chars)
D: .env file updated with new values
E: Evidence logged for security audit

New Password Lengths:
- N8N Basic Auth: ${#NEW_N8N_PASSWORD} chars
- PostgreSQL: ${#NEW_POSTGRES_PASSWORD} chars
- Traefik: $(echo $NEW_TRAEFIK_USERS | cut -d: -f2 | wc -c) chars (hashed)

Next Rotation: $(date -v+90d +%Y-%m-%d 2>/dev/null || date -d '+90 days' +%Y-%m-%d)
EOF

echo "📄 Evidence logged: $EVIDENCE_FILE"
echo ""
echo "🔐 Security Recommendations:"
echo "- Store passwords in secure password manager"
echo "- Rotate secrets every 90 days"
echo "- Never commit secrets to version control"
echo "- Use different passwords for different services"
