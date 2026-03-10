#!/usr/bin/env bash

echo "Starting homelab platform..."

docker compose pull
docker compose up -d

echo "services started."
