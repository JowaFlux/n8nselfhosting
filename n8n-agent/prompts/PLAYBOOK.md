# PLAYBOOK für VS‑Code KI (ohne Rückfragen)

1) Projektstruktur genau wie in der Baumansicht anlegen.
2) Alle Dateien mit exakt den obigen Inhalten erstellen.
3) Mac: `brew install ollama` (falls nicht vorhanden), dann `ollama serve`.
4) Modelle ziehen: `ollama pull ${CHAT_MODEL}` und `ollama pull ${EMBED_MODEL}`.
5) `.env` ausfüllen: `DATA_RETENTION=current_only`, `ALLOW_DATA_PRUNE=true`, `GDRIVE_FOLDER_ID` setzen.
6) Docker: `docker compose -f docker-compose.mac.yml up -d` (inkl. Tika-Service und Evidence-Mount).
7) Prüfen, ob n8n auf `http://localhost:5678`, Tika auf `http://localhost:9998` erreichbar sind.
8) Workflows aus `workflows/` **nicht verändern** (inkl. Proof Collector Subflow).
9) Indexer-Workflow aktualisieren: Nodes für Prune hinzufügen, IDs als `documents.id` nutzen.
10) Ersten Lauf mit `ALLOW_DATA_PRUNE=false` ausführen → prüfen `count`/`ids` → dann `true` setzen → erneut laufen lassen.
11) Nach dem Lauf: Konsistenztest `sqlite3 ./data/knowledge.sqlite "SELECT (SELECT COUNT(*) FROM documents) AS docs, (SELECT COUNT(*) FROM chunks) AS chunks;"`
12) Tests ausführen: `./scripts/test_chat.sh` und `./scripts/test_index.sh`.
13) **Proof Collector importieren** und aktivieren (für Evidenz-Sammlung).
14) Koordinator-Workflows testen: Jeder Lauf generiert Run-ID, Steps, Artifacts und Score 1-100.
15) **Report erzeugen:** `./scripts/proof_report.sh` → `./evidence/REPORT.md` mit allen Runs/Steps/Artifacts.
16) Bei Fehlern: `./bin/prune-all` und erneut **nur** die betroffenen Schritte.
17) **Selbstbewertung:** Nach jedem Schritt Konsole + Artefakt mit Score 1-100 und Begründung.
18) Ergebnis in der Konsole zusammenfassen: „OK“ oder „Fehler + Schritt + kurzer Grund“.
