#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Arret de la stack DevOps..."

cd "$ROOT/tp1/monitoring" && docker compose down 2>/dev/null || true
cd "$ROOT/tp3" && docker compose down 2>/dev/null || true
cd "$ROOT/tp2" && docker compose down 2>/dev/null || true

docker rm -f sentiment-staging prometheus grafana 2>/dev/null || true

echo "Stack arretee."
