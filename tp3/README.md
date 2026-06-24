# TP3 — SonarQube & Trivy

Qualité du code (SonarQube) et sécurité des images Docker (Trivy).

## Structure

| Fichier | Rôle |
|---------|------|
| `docker-compose.yml` | Lance SonarQube (port **9000**) |
| `setup.sh` | Démarre SonarQube + connecte Jenkins au réseau |
| `../tp1/Jenkinsfile` | Pipeline **8 stages** |

## Pipeline 8 stages

| # | Stage | Description |
|---|-------|-------------|
| 1 | Checkout | Clone Git |
| 2 | Lint | flake8 |
| 3 | Build & Test | Docker build + pytest + coverage.xml |
| 4 | SonarQube Analysis | Analyse statique |
| 5 | Quality Gate | Bloque si coverage < 70% |
| 6 | Security Scan | Trivy (CVE HIGH/CRITICAL) |
| 7 | Push | ghcr.io (main) |
| 8 | Deploy Staging | http://localhost:8001 |

## 1. Démarrer SonarQube

```bash
cd tp3
chmod +x setup.sh
./setup.sh
```

Ouvre http://localhost:9000 — login : **admin / admin**

## 2. Configurer SonarQube

1. Change le mot de passe admin
2. **Create project manually** :
   - Name : `SentimentAI`
   - Key : `sentiment-ai`
   - Branch : `main`
3. **My Account → Security → Generate Token**
   - Name : `jenkins-token`
   - Type : Global Analysis Token
4. **Quality Gates → Create** : `SentimentAI-Gate`
   - Coverage ≥ 70%
   - Reliability Rating ≥ B
5. **Project SentimentAI → Quality Gate** → assigner `SentimentAI-Gate`
6. **Administration → Webhooks → Add** :
   - URL : `http://jenkins:8080/sonarqube-webhook/` (slash final obligatoire)

## 3. Configurer Jenkins

1. **Plugins** → installer **SonarQube Scanner**
2. **Credentials → Add** :
   - Kind : Secret text
   - Secret : token SonarQube
   - ID : **`sonar-token`**
3. **Manage Jenkins → System → SonarQube servers** :
   - Name : **`sonarqube`**
   - URL : **`http://sonarqube:9000`**
   - Token : `sonar-token`

## 4. Tester Trivy manuellement

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  --severity HIGH,CRITICAL \
  --exit-code 0 \
  --format table \
  sentiment-ai:latest
```

## 5. Lancer le pipeline

Jenkins → **sentiment-ai-pipeline** → **Build Now**

Staging après deploy : http://localhost:8001/health

## Réponses aux questions

**Q1.2 — cicd-network**  
Permet à Jenkins de contacter SonarQube via `http://sonarqube:9000`. Sans réseau partagé → `UnknownHostException`.

**Q1.3 — Bug vs Code Smell**  
- **Bug** : erreur probable à l'exécution (ex. variable non définie)  
- **Code Smell** : mauvaise pratique sans bug direct (ex. fonction trop longue)

**Q2.4 — Quality Gate échoue**  
Le stage **Push** et **Deploy Staging** ne s'exécutent pas (`abortPipeline: true`).

**Q3.3 — docker.sock pour Trivy**  
Trivy a besoin du daemon Docker pour lire les layers de l'image locale.

**Q4.3 — CVE CRITICAL**  
Le pipeline s'arrête au stage **Security Scan** (si `--exit-code 1`). Push et Deploy ne s'exécutent jamais.
