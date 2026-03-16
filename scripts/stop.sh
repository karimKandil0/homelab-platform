#!/usr/bin/env bash
set -e
source .env

# Make sure .env is loaded

if [[ ! -f ".env" ]]; then
    echo "Error: .env file not found."
    echo "Run ./scripts/setup.sh first."
    exit 1
fi

# Detect Docker Compose command

if command -v docker-compose >/dev/null 2>&1; then
	COMPOSE=(docker-compose)
elif docker compose version >/dev/null 2>&1; then
	COMPOSE=(docker compose)
else
    echo "Error: Docker Compose is not available."
    echo "Install Docker Compose plugin."
    exit 1
fi

# Detect active profiles

PROFILES=()

[ "$ENABLE_VAULTWARDEN" = "Y" ] && PROFILES+=(--profile vaultwarden)
[ "$ENABLE_GITEA" = "Y" ] && PROFILES+=(--profile gitea)
[ "$ENABLE_GRAFANA" = "Y" ] && PROFILES+=(--profile grafana)

echo "Stopping homelab platform..."

"${COMPOSE[@]}" \
  "${PROFILES[@]}" \
  --env-file .env \
  -f compose/stack.yml \
  down --remove-orphans

echo "Services stopped."
