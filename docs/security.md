# Security

Pi Services is designed with security and privacy as first-class goals.

---

## DNS

- Unbound performs full recursive DNS resolution.
- DNSSEC validation is enabled.
- No dependency on third-party recursive DNS providers.

---

## Networking

- Services communicate over an isolated Docker bridge network.
- Static container addresses simplify configuration and auditing.
- Dual-stack IPv4 and IPv6 networking is supported.

---

## Remote Access

- WireGuard provides encrypted remote access.
- Only the WireGuard UDP port should be exposed to the Internet.

---

## Secrets

Environment files may contain passwords, API tokens, and private configuration.

These files are generated locally and should never be committed to version control.

---

## Updates

Regularly update container images and apply operating system security updates to keep the stack secure.