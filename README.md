# Homelab Platform

A containerized infrastructure stack for self-hosted services.

## Stack

- Vaultwarden (password manager)
- Grafana (monitoring dashboard)
- Prometheus (metrics collection)
- Node Exporter (host metrics)

## Architecture

node-exporter → Prometheus → Grafana

## Running

Start services:

docker compose up -d

Stop services:

docker compose down
