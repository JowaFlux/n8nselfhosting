# Evidence Collector (P3-Hardening)

This script automates collection of the P3-Hardening evidence pack required by the Koordinator.

Files added:
- `scripts/collect_p3_evidence.sh` — collects env snapshot, http checks, rest settings, logs and meta, packages into `/data/proofs/P3-evidence-YYYYmmdd-HHMM.tar.gz`.

Usage
-----

1. Ensure the repository is available on the host running the services and that `docker` + `jq` are installed.
2. (Optional) Export admin password for authenticated checks:

```bash
export N8N_ADMIN_PASSWORD="your_admin_password"
```

3. Run the collector (as a user with permission to run docker):

```bash
bash scripts/collect_p3_evidence.sh
```

Output
------
The script writes an archive to `/data/proofs/` named `P3-Hardening-evidence-YYYYmmdd-HHMM.tar.gz`.

Notes
-----
- Secrets are masked in `n8n-env.txt` where possible. Do not commit raw passwords.
- If `N8N_ADMIN_PASSWORD` is not provided the authenticated UI check is skipped and a note is written.

If you want this to run automatically after changes, add a small cron job or an n8n subflow to trigger it.
