#!/usr/bin/env bash
set -euo pipefail

echo "==> Arrêt du conteneur SentimentAI sur le port 8080 (conflit avec Jenkins)"
docker compose -f ../tp1/docker-compose.yml down 2>/dev/null || true

echo "==> Démarrage de Jenkins"
docker compose up -d

echo "==> Attente du démarrage de Jenkins..."
for i in $(seq 1 60); do
  if curl -sf http://localhost:8080/login >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "==> Installation de Docker CLI dans le conteneur Jenkins (DooD)"
docker exec -u root jenkins bash -c "
  if ! command -v docker >/dev/null 2>&1; then
    apt-get update -q
    apt-get install -y docker.io
  fi
  chmod 666 /var/run/docker.sock 2>/dev/null || true
"

echo "==> Vérification Docker depuis Jenkins"
docker exec -u jenkins jenkins docker ps

echo ""
echo "Jenkins est prêt : http://localhost:8080"
echo ""
echo "Mot de passe initial :"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
