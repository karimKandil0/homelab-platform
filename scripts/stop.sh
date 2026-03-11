#!/usr/bin/env bash

echo "Stopping homelab platform..."

docker compose -f ../compose/stack.yml down

echo "Services stopped."
