# Proof Collector (n8n)

This is a small n8n workflow template to collect P1–P8 evidence metadata and write a short entry into `chat_logs.jsonl` (or a dedicated log file). It is intended as a lightweight in-workflow evidence emitter — the heavy lifting (packaging logs, running docker commands) is done by `scripts/collect_p3_evidence.sh` on the host.

Import
------
1. In n8n: Workflows → Import from file → select `agents/flows/proof_collector.json`.
2. Assign Google Drive credential in the Drive Append node and ensure `LOG_FILE_ID` env is set.
3. Activate the workflow.

Usage
-----
Send a POST to the webhook path `/webhook/proof-collector` with body:

```json
{
  "task": "P3-Hardening",
  "who": "n8n-Agent",
  "evidencePath": "/data/proofs/P3-evidence-20250909-1053.tar.gz"
}
```

The workflow appends a short JSON line to the log file and responds with the same JSON.

Notes
-----
- This workflow is intentionally minimal — it's a trigger and logger. The real evidence pack is produced by the host script.
- Ensure Drive credential and `LOG_FILE_ID` are present.
