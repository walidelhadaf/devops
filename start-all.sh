#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export TF_VAR_docker_host="unix://${HOME}/.docker/run/docker.sock"

echo "=========================================="
echo "  Demarrage stack DevOps complete (TP1-5)"
echo "=========================================="

# Attendre Docker
echo ""
echo "[0/6] Attente de Docker..."
for i in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    echo "Docker OK"
    break
  fi
  if [ "$i" -eq 1 ]; then
    echo "Lancement de Docker Desktop..."
    open -a Docker 2>/dev/null || true
  fi
  sleep 3
done
docker info >/dev/null 2>&1 || { echo "ERREUR: Docker non disponible. Lance Docker Desktop."; exit 1; }

# Reseau partage
echo ""
echo "[1/6] Reseau tp2_cicd-network..."
docker network inspect tp2_cicd-network >/dev/null 2>&1 || \
  docker network create tp2_cicd-network

# Jenkins (TP2) — port 8080
echo ""
echo "[2/6] Jenkins (TP2)..."
cd "$ROOT/tp2"
docker compose up -d
docker exec -u root jenkins bash -c '
  command -v docker >/dev/null || apt-get update -q && apt-get install -y docker.io
  chmod 666 /var/run/docker.sock 2>/dev/null || true
' 2>/dev/null || true
docker network connect tp2_cicd-network jenkins 2>/dev/null || true

# SonarQube (TP3) — port 9000
echo ""
echo "[3/6] SonarQube (TP3)..."
cd "$ROOT/tp3"
docker compose up -d
docker network connect tp2_cicd-network jenkins 2>/dev/null || true

# Build image + Terraform staging + monitoring (TP4 + TP5)
echo ""
echo "[4/6] Build image SentimentAI..."
cd "$ROOT/tp1"
docker build -t sentiment-ai:latest . -q

echo ""
echo "[5/6] Terraform — staging + Prometheus + Grafana (TP4/TP5)..."
cd "$ROOT/tp1/infra"
terraform init -input=false >/dev/null 2>&1 || terraform init -input=false
terraform apply -auto-approve -var='image_tag=latest'

# Attendre les services
echo ""
echo "[6/6] Verification des services..."
sleep 15

check() {
  local name="$1" url="$2"
  if curl -sf "$url" >/dev/null 2>&1; then
    echo "  OK  $name — $url"
  else
    echo "  ... $name — $url (demarre encore)"
  fi
}

check "Jenkins"      "http://localhost:8080/login"
check "SonarQube"    "http://localhost:9000"
check "SentimentAI"  "http://localhost:8001/health"
check "Prometheus"   "http://localhost:9090/-/healthy"
check "Grafana"      "http://localhost:3000/api/health"

echo ""
echo "=========================================="
echo "  Stack demarree !"
echo "=========================================="
echo ""
echo "  Jenkins     : http://localhost:8080"
echo "  SonarQube   : http://localhost:9000  (admin / ton mot de passe)"
echo "  SentimentAI : http://localhost:8001/health"
echo "  Prometheus  : http://localhost:9090/targets"
echo "  Grafana     : http://localhost:3000  (admin / admin)"
echo ""
echo "  Mot de passe initial Jenkins :"
echo "    cd tp2 && make jenkins-password"
echo ""
echo "  Arreter tout : ./stop-all.sh"
echo ""
