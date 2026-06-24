# TP4 — Terraform IaC

Provisionner l'environnement staging SentimentAI avec Terraform (Docker provider).

## Structure

```
tp1/infra/
├── main.tf        # Provider Docker + reseau + image + conteneur
├── variables.tf   # image_tag, app_port, network_name...
└── outputs.tf     # container_id, app_url, network_name
```

## 1. Installer Terraform (macOS)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

## 2. Tester en local

```bash
cd tp1/infra

# macOS Docker Desktop
export TF_VAR_docker_host="unix://$HOME/.docker/run/docker.sock"

# Construire l'image si necessaire
cd .. && docker build -t sentiment-ai:latest . && cd infra

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
curl http://localhost:8001/health

# Idempotence
terraform apply   # → No changes
```

## 3. Installer Terraform dans Jenkins

```bash
cd tp4
chmod +x install-terraform-jenkins.sh
./install-terraform-jenkins.sh
```

## 4. Pipeline Jenkins — 10 stages

| # | Stage |
|---|-------|
| 1 | Checkout |
| 2 | Lint |
| 3 | **IaC Validate** |
| 4 | Build & Test |
| 5 | SonarQube Analysis |
| 6 | Quality Gate |
| 7 | Security Scan |
| 8 | Push |
| 9 | **IaC Apply** |
| 10 | Deploy Staging (curl health) |

Jenkins → **Build Now**

## Notes

- Reseau utilise : `tp2_cicd-network` (cree au TP2)
- Port staging : **8001** (8080 = Jenkins)
- Image locale `sentiment-ai:TAG` buildee par Jenkins (pas de pull registry)
- Si conteneur `sentiment-staging` existe deja : `docker rm -f sentiment-staging`

## Reponses aux questions

**Q1.2** — `.terraform/` contient les providers telecharges par `terraform init`. Regenerable, ne pas versionner.

**Q2.1** — `docker_image.sentiment.image_id` cree une dependance explicite : Terraform attend que l'image existe avant de creer le conteneur.

**Q2.2** — `keep_locally = true` evite que Terraform supprime l'image locale au `destroy`.

**Q3.3** — 2e apply sans changement = idempotent, safe en CI/CD.

**Q4.2** — Validate sur toutes branches (fail fast syntaxe) ; Apply seulement sur main (deploy reel).

**Q4.3** — `-var image_tag=${IMAGE_TAG}` lie l'infra au commit exact builde par Jenkins.
