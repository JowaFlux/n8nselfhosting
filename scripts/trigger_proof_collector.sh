#!/usr/bin/env bash
set -euo pipefail

# Simple helper to trigger the proof-collector webhook and (optionally) run the host evidence collector
URL="http://localhost:5678/webhook/proof-collector"
PAYLOAD="{\"task\":\"P1\",\"who\":\"n8n-Agent\",\"evidencePath\":\"/data/proofs/P1-evidence-$(date -u +%Y%m%d-%H%M).tar.gz\"}"

echo "Triggering Proof-Collector at ${URL}"
echo "Payload: ${PAYLOAD}"

RESPONSE=$(curl -s -X POST "${URL}" -H 'Content-Type: application/json' -d "${PAYLOAD}")
echo "Response: ${RESPONSE}"

if [ -x ./scripts/collect_p3_evidence.sh ]; then
  echo "Running host-side evidence collection (collect_p3_evidence.sh)"
  bash ./scripts/collect_p3_evidence.sh
else
  echo "Host-side evidence collector not present or not executable; skipping pack creation."
fi

echo "Done."
