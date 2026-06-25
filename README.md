# DevOps — Travaux pratiques

Dépôt regroupant les 5 TPs DevOps dans un même projet.

## Demarrer / Arreter toute la stack

```bash
chmod +x start-all.sh stop-all.sh
./start-all.sh    # demarre Jenkins, SonarQube, staging, Prometheus, Grafana
./stop-all.sh     # arrete tout
```

| Service | URL |
|---------|-----|
| Jenkins | http://localhost:8080 |
| SonarQube | http://localhost:9000 |
| SentimentAI | http://localhost:8001 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 (admin/admin) |

| Dossier | Sujet | Statut |
|---------|-------|--------|
| [tp1/](tp1/) | Git & Docker — SentimentAI | Terminé |
| [tp2/](tp2/) | Jenkins pipeline | En cours |
| [tp3/](tp3/) | SonarQube & Trivy | En cours |
| [tp4/](tp4/) | Terraform IaC | En cours |
| [tp5/](tp5/) | Monitoring Prometheus/Grafana | En cours |

## TP1 — Commandes rapides

```bash
cd tp1
make build
make test
make run
make stop
```

Depuis la racine :

```bash
make tp1-build
make tp1-test
make tp1-run
make tp1-stop
```

## TP2 — Commandes Jenkins

```bash
cd tp2
./setup.sh          # démarre Jenkins + installe Docker CLI
make jenkins-logs
make jenkins-password
```

Jenkins : http://localhost:8080 — Script Path du job : `tp1/Jenkinsfile`

## TP3 — SonarQube & Trivy

```bash
cd tp3
./setup.sh
```

SonarQube : http://localhost:9000 — Pipeline 10 stages dans `tp1/Jenkinsfile`

## TP4 — Terraform

```bash
cd tp1/infra
export TF_VAR_docker_host="unix://$HOME/.docker/run/docker.sock"
terraform init && terraform apply
cd ../../tp4 && ./install-terraform-jenkins.sh
```

## TP5 — Monitoring

```bash
cd tp1 && docker build -t sentiment-ai:latest .
cd infra && terraform apply -auto-approve -var='image_tag=latest'
cd ../../tp5 && ./setup.sh
```

Prometheus : http://localhost:9090 — Grafana : http://localhost:3000
