#!/usr/bin/env bash
set -euo pipefail

echo "🚀 n8n-Agent Acceptance Test - FINAL RUN"
echo "========================================"

# 1) Services starten & verifizieren
echo ""
echo "1) Starting services..."
cd /Users/macbook/Downloads/n8nselfhosting/n8n-agent

echo "   Starting Docker services..."
./bin/dev-up mac

echo "   Verifying services..."
mkdir -p ./evidence

# Check n8n
N8N_STATUS=$(curl -sI http://localhost:5678 | head -n1 || echo "Failed")
echo "n8n: $N8N_STATUS" > ./evidence/BOOTCHECK.txt

# Check Tika
TIKA_STATUS=$(curl -sI http://localhost:9998/tika | head -n1 || echo "Failed")
echo "Tika: $TIKA_STATUS" >> ./evidence/BOOTCHECK.txt

# Check Ollama
OLLAMA_MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[]?.name' 2>/dev/null || echo "Failed")
echo "Ollama models: $OLLAMA_MODELS" >> ./evidence/BOOTCHECK.txt

echo "   Boot check saved to ./evidence/BOOTCHECK.txt"
cat ./evidence/BOOTCHECK.txt

# 2) DB vorbereiten
echo ""
echo "2) Preparing database..."
DB_RESULT=$(./scripts/test_index.sh 2>&1 || echo "Failed")
echo "$DB_RESULT" > ./evidence/DBCHECK.txt
echo "   DB check saved to ./evidence/DBCHECK.txt"
cat ./evidence/DBCHECK.txt

# 3) Manual step reminder
echo ""
echo "3) 📝 MANUAL STEP REQUIRED:"
echo "   - Open http://localhost:5678 in browser"
echo "   - Import workflows: proof_collector.json, indexer_template.json, koordinator_minimal.json, koordinator_loop_template.json"
echo "   - Map credentials: DRIVE_READONLY, SHEETS_READONLY"
echo "   - Activate all workflows"
echo ""
echo "   Press Enter when ready to continue..."
read -r

# 4) Indexer Full-Sync
echo ""
echo "4) Running indexer (current-only sync)..."
echo "   ⚠️  MANUAL: Start indexer workflow in n8n UI"
echo "   Waiting for completion..."
echo ""
echo "   Press Enter when indexer is complete..."
read -r

# Check indexer results
INDEX_RESULT=$(sqlite3 ./data/knowledge.sqlite "SELECT COUNT(*) AS docs FROM documents; SELECT COUNT(*) AS chunks FROM chunks;" 2>/dev/null || echo "Failed")
echo "$INDEX_RESULT" > ./evidence/INDEX_CHECK.txt
echo "   Index check saved to ./evidence/INDEX_CHECK.txt"
cat ./evidence/INDEX_CHECK.txt

# 5) Koordinator-Runs
echo ""
echo "5) Testing coordinators with proof collection..."

# Minimal coordinator
echo "   Testing minimal coordinator..."
MINIMAL_RESPONSE=$(curl -s -X POST http://localhost:5678/webhook/agent/run \
  -H 'Content-Type: application/json' \
  -d '{"task":"Erstelle eine kompakte JSON-Architektur für meinen RAG-Agenten."}' || echo "Failed")
echo "   Minimal response received"

# RAG + Loop coordinator
echo "   Testing RAG + Loop ≥950 coordinator..."
LOOP_RESPONSE=$(curl -s -X POST http://localhost:5678/webhook/agent/run-950 \
  -H 'Content-Type: application/json' \
  -d '{"task":"Plane Sub-Agenten (Research, Evaluator, Publisher) auf Basis der Ordner-RAG. Liefere strikt JSON, inkl. Quellen. Ziel ≥950/1000."}' || echo "Failed")
echo "   Loop response received"

# Generate proof report
echo "   Generating proof report..."
./scripts/proof_report.sh
echo "   Report saved to ./evidence/REPORT.md"

# 6) GitHub-Sync & Team-Log
echo ""
echo "6) GitHub sync and team logs..."

# Git init & push
echo "   Initializing GitHub sync..."
./scripts/git_init_push.sh

# Generate reports
echo "   Generating Git report..."
./scripts/git_report.sh

echo "   Generating audit aggregate..."
./scripts/audit_aggregate.sh

# Final commit
echo "   Committing all changes..."
git add -A
git commit -m "chore: acceptance run (current-only RAG + proof + ≥950 loop)" || echo "No changes to commit"
git push || echo "Push failed - check authentication"

# 7) Final verification
echo ""
echo "7) Final verification..."
echo "   Checking evidence files:"
ls -la ./evidence/

echo ""
echo "   Checking latest run score:"
sqlite3 ./data/knowledge.sqlite "SELECT run_id, status, score, summary FROM runs ORDER BY started_at DESC LIMIT 1;" 2>/dev/null || echo "No runs found"

echo ""
echo "🎉 ACCEPTANCE TEST COMPLETE!"
echo "   📊 Check ./evidence/REPORT.md for proof collection results"
echo "   🔗 GitHub repo: $(cat ./evidence/GIT_REMOTE.txt 2>/dev/null || echo 'Not set')"
echo "   📈 Audit log: ./evidence/AUDIT_LOG.md"
