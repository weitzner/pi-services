# Configuration

Most deployment-specific settings are stored in two environment files created by `initialize-config-files.sh`.

---

## services/.env

Configures the Docker services.

Common settings include:

- Time zone (`TZ`)
- User and group IDs (`PUID`, `PGID`)
- Raspberry Pi IP address
- Service ports
- Pi-hole administrator password
- Local DNS records
- WireGuard configuration

---

## scripts/.env

Configures the Cloudflare Dynamic DNS updater.

Required values:

- `ZONE_ID`
- `DNS_RECORD_ID`
- `CLOUDFLARE_API_TOKEN`

This file is only needed if you use the included Dynamic DNS updater.

---

## Local Configuration

Additional configuration files are generated in `services/local_config/`.

| File | Purpose |
|------|---------|
| `local_dns.conf` | Local DNS records for Pi-hole |
| `vpn_peers.conf` | WireGuard peer names |

Helper scripts convert these files into the format expected by `services/.env`.

---

## Applying Changes

After updating the configuration, restart the affected services.

```bash
docker compose up -d
```

or

```bash
docker compose restart
```