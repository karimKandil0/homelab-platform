#!/usr/bin/env bash
set -e

echo "Starting homelab platform..."

if [ ! -f .env ]; then
  cp .env.example .env
  echo ".env file created from template"
fi

docker compose -f compose/stack.yml pull
docker compose \
  --env-file .env \
  -f compose/stack.yml \
  up -d

echo ""
echo "Services are starting..."
echo ""
echo "Services started!"
echo "Access them at:"
echo ""
echo "vaultwarden -> http://$VAULT_HOST:$PORT"
echo "gitea -> http://$GITEA_HOST:$PORT"
echo "grafana -> http://$GRAFANA_HOST:$PORT"
