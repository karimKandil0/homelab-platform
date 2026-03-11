#!/usr/bin/env bash
set -e

echo "Stopping homelab platform..."

docker compose \
  --env-file .env \
  -f compose/stack.yml \
  down

echo "Services stopped."
