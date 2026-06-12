#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Arquivo .env criado a partir de .env.example"
fi

docker compose up -d
echo "PostgreSQL disponivel em localhost:${POSTGRES_PORT:-5432}"
