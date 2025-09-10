Funkmeldung Vorlage (SOP) - ein Post pro Rolle

UTC: YYYY-MM-DDTHH:MM:SSZ
Absenderrolle: @<Role>

1. Aktion:
- Kurz: Welche Tätigkeit wurde ausgeführt? (ein Satz)

2. Test / Proof-of-Work:
- Kurze Beschreibung der Tests (cURL, Executions-ID, Logs)
- Konkrete Artefakte mit Pfaden (z. B. /data/proofs/P1-evidence-...tar.gz)

3. Ergebnis:
- Kurz: Ergebnis in einem Satz (PASS/FAIL) und ggf. Score

4. Artefakte / Referenzen:
- Liste der Dateien/Links (evidence archive, execution API URL, drive file id, logs)

5. Status:
- ✅ abgeschlossen / 🔄 in Loop / ⛔ Blocker

Beispiel
------
UTC: 2025-09-09T12:34:00Z
Absenderrolle: @n8n-Agent
1. Aktion: Proof-Collector importiert, aktiviert und Webhook-Test ausgeführt.
2. Test / Proof-of-Work: cURL POST to /webhook/proof-collector -> 200, Executions: 801 (success). Evidence pack: /data/proofs/P1-evidence-20250909-1230.tar.gz
3. Ergebnis: PASS — Evidence pack created, Score >= 950
4. Artefakte / Referenzen: /data/proofs/P1-evidence-20250909-1230.tar.gz, Execution API: http://localhost:5678/rest/executions/801, Drive file ID: abc***456
5. Status: ✅ abgeschlossen
