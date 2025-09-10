# n8n Development Setup (npm)

Dieses Setup ermöglicht eine unabhängige Entwicklungsinstanz von n8n neben der Docker-Produktion.

## 1. Umgebung vorbereiten
- Neue VM oder freien Port (z. B. 5679) nutzen
- Node.js LTS (20.19–24.x) installieren

## 2. n8n via npm installieren
```sh
sudo npm install -g n8n
n8n --version
```

## 3. Systemnutzer & Arbeitsverzeichnis
```sh
sudo useradd -r -m -s /usr/sbin/nologin n8n
sudo mkdir -p /opt/n8n && sudo chown -R n8n:n8n /opt/n8n
```

## 4. .env für Dev-Setup
Pfad: `/opt/n8n/.env`
```
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n-dev.example.com
N8N_HOST=0.0.0.0
N8N_PORT=5679
N8N_PROXY_HOPS=1
GENERIC_TIMEZONE=Europe/Zurich

N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=devadmin
N8N_BASIC_AUTH_PASSWORD=please-change
```

## 5. systemd-Service erstellen
Pfad: `/etc/systemd/system/n8n-dev.service`
```
[Unit]
Description=n8n (npm) dev service
After=network.target

[Service]
Type=simple
User=n8n
WorkingDirectory=/opt/n8n
EnvironmentFile=/opt/n8n/.env
ExecStart=/usr/bin/env bash -lc 'n8n start'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
Aktivieren:
```sh
sudo systemctl daemon-reload
sudo systemctl enable --now n8n-dev
sudo systemctl status n8n-dev
```

## 6. Traefik erweitern
- Subdomain `n8n-dev.example.com` auf `http://<server-ip>:5679` routen
- SSL via Let’s Encrypt wie bei Produktion

## 7. Test
```sh
curl -I https://n8n-dev.example.com
```
Status 200/302, Login: devadmin + Passwort aus .env

## Update
```sh
sudo npm update -g n8n
sudo systemctl restart n8n-dev
```

## Flow-Sync aus Repo
- Die Dev-Instanz importiert Flows automatisch aus `agents/flows/*.json` via Skript `scripts/import_flows_dev.sh`.
- Automatisierung per Cronjob oder GitHub Action möglich.
- Ergebnis-Log unter `reports/dev_import_<timestamp>.log`.

### Beispiel-Cronjob
Täglicher Import um 02:00 Uhr:
```
0 2 * * * /bin/bash /path/to/scripts/import_flows_dev.sh
```

### Beispiel GitHub Action
```yaml
name: Import n8n Dev Flows
on:
	push:
		branches:
			- main
jobs:
	import-flows:
		runs-on: ubuntu-latest
		steps:
			- name: Checkout code
				uses: actions/checkout@v4
			- name: Import Flows to n8n Dev
				run: |
					bash scripts/import_flows_dev.sh
```

---

Erledigt – @VS Entwickler
