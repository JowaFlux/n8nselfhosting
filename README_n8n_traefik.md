# n8n + Traefik Selfhosting – Projektdokumentation

## Architektur

```mermaid
graph TD
    subgraph Traefik
        traefik[Traefik (SSL/TLS, Dashboard)]
    end
    subgraph n8n
        n8n[n8n]
    end
    subgraph Postgres
        db[(Postgres)]
    end
    traefik -- HTTPS 443 --> n8n
    traefik -- Dashboard HTTPS 443 --> traefik
    n8n -- DB --> db
    n8n -- Volumes --> data_n8n[(./data/n8n)]
    db -- Volumes --> data_db[(./data/postgres)]
    traefik -- Certs --> letsencrypt[(./data/letsencrypt)]
    github[GitHub Actions] -- CI/CD --> traefik
    github -- CI/CD --> n8n
    github -- CI/CD --> db
```

## Start/Stop
```sh
docker compose up -d
docker compose down
```

## Logs & Health
```sh
docker compose ps
docker compose logs traefik
docker compose logs n8n
docker compose logs postgres
curl -I https://$N8N_DOMAIN/healthz
```

## Backup & Restore
Backup:
```sh
/bin/bash ./backup.sh
```
Restore:
```sh
gunzip < ./backups/postgres/DATE.sql.gz | docker compose exec -T postgres psql -U "$POSTGRES_USER" "$POSTGRES_DB"
```

## CI/CD Deploy
Push auf main startet automatisches Deploy:
- git pull
- docker compose pull
- docker compose up -d --remove-orphans

## Security
- Traefik-Dashboard per Basic Auth (bcrypt) und optional IP-Whitelist geschützt
- SSL/TLS via Let's Encrypt
- Firewall: Ports 80/443 offen
- Starke Passwörter in .env

## Disaster Recovery Checklist
- Backups täglich, 14 Tage Aufbewahrung
- Restore-Test regelmäßig durchführen
- Logs und Healthchecks prüfen

## Troubleshooting
- docker compose ps/logs prüfen
- Zertifikate: ./data/letsencrypt/acme.json
- Healthcheck: curl -I https://$N8N_DOMAIN/healthz

## Future Extensions
- Monitoring (Prometheus/Grafana)
- Agenten-Integration
- Alerting
- Skalierung

---

Erledigt – @VS Entwickler
