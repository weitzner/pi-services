# Services

Pi Services consists of five Docker containers that work together to provide DNS, VPN, home automation, and reverse proxy services.

---

## Pi-hole

Provides network-wide DNS filtering and ad blocking for all clients.

- Primary DNS server for LAN and VPN clients
- Filters ads, trackers, and malicious domains
- Forwards DNS queries to Unbound

Project: https://pi-hole.net

---

## Unbound

Provides a fully recursive, DNSSEC-validating DNS resolver.

- Resolves queries directly from the Internet DNS hierarchy
- Validates DNSSEC
- Caches responses to improve performance
- No dependency on public recursive DNS providers

Project: https://nlnetlabs.nl/projects/unbound/

---

## WireGuard

Provides secure remote access to the home network.

- Modern, high-performance VPN
- Client configurations generated automatically
- Supports QR codes for mobile devices

Project: https://www.wireguard.com

---

## Homebridge

Adds Apple HomeKit support for devices that are not HomeKit-native.

- Runs in host networking mode
- Supports mDNS discovery
- Managed through a web interface

Project: https://homebridge.io

---

## nginx

Provides a lightweight reverse proxy for locally hosted services.

- Routes friendly hostnames to local services
- Template-based configuration
- Easily extended for additional applications

Project: https://nginx.org