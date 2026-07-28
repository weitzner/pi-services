# Installation

## Requirements

- Raspberry Pi running Debian or Raspberry Pi OS
- Docker Engine + Docker Compose
- Static IP address (recommended)

Install Docker using the official guide:

https://docs.docker.com/engine/install/debian/

---

## Install Pi Services

```bash
git clone https://github.com/weitzner/pi-services.git
cd pi-services

./initialize-config-files.sh
```

Edit:

```
services/.env
scripts/.env
```

Start the stack:

```bash
docker compose up -d
```

Verify:

```bash
docker compose ps
```

---

## Next

- [Configuration](configuration.md)
- [Networking](networking.md)
- [Services](services.md)