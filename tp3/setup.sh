#!/usr/bin/env bash
set -euo pipefail

echo "==> Vérifier le réseau Docker partagé"
docker network inspect tp2_cicd-network >/dev/null 2>&1 || {
  echo "Réseau tp2_cicd-network introuvable. Lance d'abord Jenkins : cd tp2 && ./setup.sh"
  exit 1
}

echo "==> Démarrage de SonarQube"
docker compose up -d

echo "==> Attente du démarrage (~60s)..."
for i in $(seq 1 60); do
  if curl -sf http://localhost:9000/api/system/status 2>/dev/null | grep -q UP; then
    echo "SonarQube est opérationnel."
    break
  fi
  sleep 2
done

echo "==> Connexion de Jenkins au réseau (si pas déjà fait)"
docker network connect tp2_cicd-network jenkins 2>/dev/null || true

echo ""
echo "SonarQube : http://localhost:9000"
echo "Login par défaut : admin / admin (change le mot de passe au 1er login)"
echo ""
echo "Prochaines étapes :"
echo "  1. Créer le projet SentimentAI (project key: sentiment-ai)"
echo "  2. Générer un token : My Account > Security > Generate Token"
echo "  3. Jenkins > Credentials > sonar-token (Secret text)"
echo "  4. Jenkins > System > SonarQube servers > http://sonarqube:9000"
echo "  5. Installer le plugin SonarQube Scanner dans Jenkins"
echo "  6. SonarQube > Webhooks > http://jenkins:8080/sonarqube-webhook/"
