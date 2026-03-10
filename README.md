# Homelab Platform

A modular self-hosted infrastructure platform built with **Docker Compose**, **Traefik**, and **Prometheus/Grafana** for monitoring.

This project demonstrates how to build a small platform that can run and monitor multiple services behind a reverse proxy with observability.

---

# Architecture

```
                Browser
                   │
                   ▼
            Traefik (Reverse Proxy)
                :8088 entrypoint
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   Vaultwarden   Grafana   Prometheus
                                 │
                                 ▼
                           Node Exporter
                           (system metrics)
```

### Traffic Flow

```
Browser → Traefik → Service Container
```

Example:

```
vault.localhost:8088 → Vaultwarden
grafana.localhost:8088 → Grafana
prometheus.localhost:8088 → Prometheus
```

---

# Stack

### Reverse Proxy

* **Traefik**
* Dynamic Docker service discovery
* Host-based routing
* Central entrypoint for all services

---

### Monitoring

* **Prometheus** – metrics collection
* **Grafana** – visualization dashboards
* **Node Exporter** – host system metrics

Metrics pipeline:

```
node-exporter → Prometheus → Grafana
```

Collected metrics include:

* CPU usage
* Memory usage
* Disk I/O
* Network usage

---

### Services

#### Vaultwarden

Lightweight Bitwarden-compatible password manager.

#### Grafana

Visualization dashboards for system monitoring.

#### Prometheus

Time-series database used for metrics collection.

#### Node Exporter

Exports Linux host metrics for Prometheus.

---

# Project Structure

```
homelab-platform
│
├── docker-compose.yml
│
├── services
│   ├── vaultwarden
│   │   └── data
│   ├── grafana
│   │   └── data
│   └── node-exporter
│
├── monitoring
│   └── prometheus
│       └── prometheus.yml
│
└── README.md
```

---

# Running the Platform

### Requirements

* Docker
* Docker Compose

### Start all services

```bash
docker compose up -d
```

### Check running containers

```bash
docker ps
```

### Stop services

```bash
docker compose down
```

---

# Service Endpoints

| Service           | URL                              |
| ----------------- | -------------------------------- |
| Vaultwarden       | http://vault.localhost:8088      |
| Grafana           | http://grafana.localhost:8088    |
| Prometheus        | http://prometheus.localhost:8088 |
| Traefik Dashboard | http://localhost:8080            |

---

# Observability

Prometheus scrapes metrics from the Node Exporter:

```
http://node-exporter:9100/metrics
```

Grafana dashboards visualize system metrics such as:

* CPU utilization
* Memory usage
* Disk space
* Network activity

---

# Why This Project Exists

This repository is a learning project focused on:

* containerized infrastructure
* reverse proxy architecture
* service routing
* monitoring and observability
* self-hosted platforms

The goal is to build a modular infrastructure stack that can easily scale with additional services.

---

# Planned Improvements

Future additions include:

* TLS with Traefik + Let's Encrypt
* additional services (Immich / Jellyfin / MinIO)
* automated backups
* infrastructure scripts
* environment configuration
* monitoring alerts
* CI validation for Docker Compose

---

# License

MIT

