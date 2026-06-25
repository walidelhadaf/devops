#!/usr/bin/env bash
set -euo pipefail

echo "==> Demarrage Prometheus + Grafana"
cd "$(dirname "$0")/../tp1/monitoring"
docker compose up -d

echo ""
echo "Prometheus : http://localhost:9090"
echo "Grafana    : http://localhost:3000 (admin / admin)"
echo ""
echo "Datasource Grafana : http://prometheus:9090"
echo "Target Prometheus  : sentiment-staging:8000"
