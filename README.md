# DevOps — Travaux pratiques

Dépôt regroupant les 5 TPs DevOps dans un même projet.

| Dossier | Sujet | Statut |
|---------|-------|--------|
| [tp1/](tp1/) | Git & Docker — SentimentAI | Terminé |
| [tp2/](tp2/) | Jenkins pipeline | En cours |
| [tp3/](tp3/) | SonarQube & Trivy | En cours |
| [tp4/](tp4/) | Terraform IaC | À faire |
| [tp5/](tp5/) | Monitoring Prometheus/Grafana | À faire |

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

SonarQube : http://localhost:9000 — Pipeline 8 stages dans `tp1/Jenkinsfile`
