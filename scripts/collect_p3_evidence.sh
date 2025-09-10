#!/usr/bin/env bash
set -euo pipefail

# collect_p3_evidence.sh
# Collects P3-Hardening evidence as specified by the coordinator and packages
# it into /data/proofs/P3-evidence-YYYYmmdd-HHMM.tar.gz

EVIDENCE_DIR="evidence"
# Prefer /data/proofs (per coordinator), but fall back to workspace ./data/proofs if not writable
DEFAULT_OUT_DIR="/data/proofs"
FALLBACK_OUT_DIR="$(pwd)/data/proofs"

OUT_DIR="${DEFAULT_OUT_DIR}"
if [ ! -w "$(dirname "${OUT_DIR}")" ] || [ ! -d "$(dirname "${OUT_DIR}")" ] && [ ! -w "$(dirname "${OUT_DIR}")" ]; then
  OUT_DIR="${FALLBACK_OUT_DIR}"
  echo "[WARN] /data not writable; falling back to ${OUT_DIR}"
fi
TASK="P3-Hardening"
TIMESTAMP=$(date -u +%Y%m%d-%H%M)
OUT_TAR="${OUT_DIR}/${TASK}-evidence-${TIMESTAMP}.tar.gz"

mkdir -p "${EVIDENCE_DIR}"
mkdir -p "${OUT_DIR}"

# Helper to mask secrets in outputs
mask() {
  sed -E 's/([A-Za-z0-9_\-]{3})[A-Za-z0-9_\-]+([A-Za-z0-9_\-]{3})/\1***\2/g'
}

echo "[INFO] Collecting evidence for ${TASK} at ${TIMESTAMP} UTC"

START_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# A. Env-Snapshot (sanitised)
docker inspect n8n --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | \
  egrep '^(N8N_BASIC_AUTH_ACTIVE|N8N_BASIC_AUTH_USER|WEBHOOK_URL)=' || true > "${EVIDENCE_DIR}/n8n-env.raw.txt"

# Mask any obvious secrets for safety
mask < "${EVIDENCE_DIR}/n8n-env.raw.txt" > "${EVIDENCE_DIR}/n8n-env.txt" || true

# B. Basic-Auth checks (requires N8N_ADMIN_PASSWORD env for the auth test)
HTTP_NOAUTH_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:5678/ || true)
echo "${HTTP_NOAUTH_CODE}" > "${EVIDENCE_DIR}/http-ui-noauth.code"

if [ -z "${N8N_ADMIN_PASSWORD:-}" ]; then
  echo "[WARN] N8N_ADMIN_PASSWORD not set; skipping authenticated UI check. Set N8N_ADMIN_PASSWORD env to run this check." > "${EVIDENCE_DIR}/http-ui-auth.note"
else
  HTTP_AUTH_CODE=$(curl -s -u admin:"${N8N_ADMIN_PASSWORD}" -o /dev/null -w '%{http_code}' http://localhost:5678/ || true)
  echo "${HTTP_AUTH_CODE}" > "${EVIDENCE_DIR}/http-ui-auth.code"
fi

# C. WEBHOOK_URL effective settings (requires auth if set)
if [ -z "${N8N_ADMIN_PASSWORD:-}" ]; then
  curl -s http://localhost:5678/rest/settings | jq '.endpointWebhook,.endpointWebhookTest' > "${EVIDENCE_DIR}/rest-settings.json" 2>/dev/null || true
else
  curl -s -u admin:"${N8N_ADMIN_PASSWORD}" http://localhost:5678/rest/settings | jq '.endpointWebhook,.endpointWebhookTest' > "${EVIDENCE_DIR}/rest-settings.json" 2>/dev/null || true
fi

# D. Container status & logs
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' > "${EVIDENCE_DIR}/docker-ps.txt" 2>/dev/null || true
docker logs --since 30m n8n > "${EVIDENCE_DIR}/n8n-logs.txt" 2>/dev/null || true

# E. Meta
END_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DURATION_SEC=0
if command -v python3 >/dev/null 2>&1; then
  DURATION_SEC=$(python3 - <<PY
from datetime import datetime
start = datetime.strptime("${START_UTC}", "%Y-%m-%dT%H:%M:%SZ")
end = datetime.strptime("${END_UTC}", "%Y-%m-%dT%H:%M:%SZ")
print(int((end-start).total_seconds()))
PY
)
fi

cat > "${EVIDENCE_DIR}/meta.json" <<EOF
{
  "task": "${TASK}",
  "who": "VS Entwickler",
  "start_utc": "${START_UTC}",
  "end_utc": "${END_UTC}",
  "duration_sec": ${DURATION_SEC},
  "notes": "Collected P3 hardening evidence. Sensitive values masked where applicable."
}
EOF

# F. Package
tar -czf "${OUT_TAR}" -C "${EVIDENCE_DIR}" .

echo "[INFO] Evidence pack created: ${OUT_TAR}"
echo "[INFO] Contents:"
tar -tzf "${OUT_TAR}"

echo "Done."
