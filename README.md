# StarterLab

A lightweight **self-hosted infrastructure platform** built with **Docker Compose and Caddy** that demonstrates how multiple services can run behind a reverse proxy with persistent storage and simple lifecycle scripts.

The goal of this project is to provide a **clean, modular reference implementation** of a small homelab or internal platform environment.

It shows how to structure:

- container orchestration
- reverse proxy routing
- environment-based configuration
- persistent service data
- reproducible infrastructure

The platform currently includes:

| Service | Purpose |
|--------|--------|
| HomePage | Homepage for all services |
| Vaultwarden | Self-hosted password manager |
| Gitea | Lightweight Git service |
| Grafana | Metrics visualization platform |
| Caddy | Reverse proxy and service router |

---

# Architecture

The platform uses a **reverse proxy architecture** where all services run behind Caddy on a shared Docker network.

Traffic from the browser enters through Caddy and is routed to services based on hostname.

```
Browser
   │
   ▼
Caddy (Reverse Proxy)
   │
   ├── Homepage
   ├── Vaultwarden
   ├── Gitea
   └── Grafana
```

Key design decisions:

- **Single entry point** through the reverse proxy
- **Docker networking** for service communication
- **Environment variables** for configuration
- **Persistent data directories** for service state
- **Simple lifecycle scripts** for startup and shutdown

More details are available in:

```
docs/architecture.md
```

---

# Quick Start

## 1. Clone the repository

```bash
git clone https://github.com/karimKandil0/homelab-platform.git
cd homelab-platform
```

---

## 3. Start the platform

```bash
./scripts/start.sh
```

Docker images will be pulled and the platform will start.

---

## 4. Access services

Once started, the services (by default) will be available at:

```
Homepage → http://home.localhost:8080
Vaultwarden → http://vault.localhost:8080
Gitea       → http://gitea.localhost:8080
Grafana     → http://grafana.localhost:8080
```

---

## 5. Stop the platform

```bash
./scripts/stop.sh
```

---

# Configuration

Platform configuration is handled through environment variables defined in:

```
.env
```

Example configuration:

```env
PORT=8080

HOME_HOST=home.localhost
VAULT_HOST=vault.localhost
GITEA_HOST=gitea.localhost
GRAFANA_HOST=grafana.localhost
```

These values are used by:

- Docker Compose
- the Caddy reverse proxy
- the startup scripts

---

# Project Structure

```
homelab-platform
│
├── compose/
│   └── stack.yml
│
├── proxy/
│   └── Caddyfile
│
├── scripts/
│   ├── start.sh
│   └── stop.sh
│
├── docs/
│   └── architecture.md
│
├── data/
│   ├── homepage/
│   ├── gitea/
│   ├── grafana/
│   └── vaultwarden/
│
├── .env.example
├── .gitignore
└── README.md
```

---

# Reverse Proxy Routing

Caddy handles routing between services.

Example configuration:

```caddy
:80 {

  @vault host vault.localhost
  reverse_proxy @vault vaultwarden:80

  @grafana host grafana.localhost
  reverse_proxy @grafana grafana:3000

  @gitea host gitea.localhost
  reverse_proxy @gitea gitea:3000

}
```

This allows services to be accessed by hostname instead of port numbers.

---

# Persistent Storage

Service data is stored in the `data/` directory.

Examples:

```
data/grafana/
data/gitea/
data/vaultwarden/
```

This ensures that:

- container restarts do not lose data
- updates are safe
- backups are possible

---

# Requirements

To run this platform you need:

- Docker
- Docker Compose
- Bash shell
- gettext

Most Linux distributions and macOS systems support this setup.

---

# Troubleshooting

## Services not accessible

Check running containers:

```bash
docker ps
```

---

## Reverse proxy issues

Check Caddy logs:

```bash
docker logs homelab-caddy
```

---

## Restart platform

```bash
./scripts/restart.sh
```

---

# Future Improvements

Possible future enhancements:

- HTTPS support with automatic certificates
- monitoring with Prometheus
- service dashboard homepage
- automatic service discovery
- additional self-hosted services

---

# License

This project is open source and available under the MIT License.
