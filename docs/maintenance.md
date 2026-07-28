# Maintenance

Routine maintenance helps keep Pi Services secure, reliable, and up to date.

---

## Update Containers

Pull the latest container images and recreate the stack.

```bash
docker compose pull
docker compose up -d
```

---

## View Logs

View logs for all services.

```bash
docker compose logs -f
```

View logs for a single service.

```bash
docker compose logs -f unbound
```

---

## Restart Services

Restart the entire stack.

```bash
docker compose restart
```

Restart an individual service.

```bash
docker compose restart pihole
```

---

## Verify Health

Check that all containers are running.

```bash
docker compose ps
```

Confirm DNS resolution.

```bash
dig google.com @<PI_IP>
```

---

## Backup

Back up the following before making significant changes:

- `services/.env`
- `scripts/.env`
- `services/local_config/`
- Homebridge configuration and persistent volumes
- WireGuard configuration and peer keys