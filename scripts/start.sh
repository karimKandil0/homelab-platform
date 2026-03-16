#!/usr/bin/env bash
START_TIME=$(date +%s)
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

if [ ! -f compose/stack.yml ]; then
    echo "Error: stack.yml not found."
    echo "Run this script from the repository root."
    exit 1
fi

echo "Starting homelab platform..."
echo ""

# Check dependencies

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

if command -v docker-compose >/dev/null 2>&1; then
	COMPOSE=(docker-compose)
elif docker compose version >/dev/null 2>&1; then
	COMPOSE=(docker compose)
else
    echo "Error: Docker Compose is not available."
    echo "Install Docker Compose plugin."
    exit 1
fi

if ! command -v envsubst &> /dev/null; then 
    echo "Error: envsubst (gettext) is not installed."
    exit 1
fi

echo ""
echo "Docker version: $(docker --version)"
echo "Compose version: $($COMPOSE version)"
echo ""

if ! docker info &> /dev/null; then
    echo "Docker daemon is not running."
    echo "Start Docker and try again."
    exit 1
fi

# Ensure .env exists

if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env file created from template"
    echo "You may want to edit it before continuing."
    echo ""
fi

# Load environment variables

set -a
source .env
set +a

# Generate config files

echo "Generating homepage configuration..."

envsubst < homepage/services.yaml.template > homepage/services.yaml

# Profiles

PROFILES=()

[ "$ENABLE_VAULTWARDEN" = "Y" ] && PROFILES+=(--profile vaultwarden)
[ "$ENABLE_GITEA" = "Y" ] && PROFILES+=(--profile gitea)
[ "$ENABLE_GRAFANA" = "Y" ] && PROFILES+=(--profile grafana)

# Pull images

echo "Pulling containers..."

"${COMPOSE[@]}" \
  "${PROFILES[@]}" \
  --env-file .env \
  -f compose/stack.yml \
  pull

# Start stack

echo "Starting containers..."

"${COMPOSE[@]}" \
  "${PROFILES[@]}" \
  --env-file .env \
  -f compose/stack.yml \
  up -d

# Success message

echo ""
echo "Services started!"
echo ""
echo "Access them at:"
echo ""

printf "  %-12s %s\n" "homepage ->" "http://$HOME_HOST:$PORT"
printf "  %-12s %s\n" "vaultwarden ->" "http://$VAULT_HOST:$PORT"
printf "  %-12s %s\n" "gitea ->" "http://$GITEA_HOST:$PORT"
printf "  %-12s %s\n" "grafana ->" "http://$GRAFANA_HOST:$PORT"

echo ""
echo "Use 'docker compose ps' to view container status."
END_TIME=$(date +%s)
echo ""
echo "Startup completed in $((END_TIME - START_TIME))s"
