#!/usr/bin/env bash
set -euo pipefail

echo "==> Installation de Terraform dans le conteneur Jenkins"
docker exec -u root jenkins bash -c '
  if command -v terraform >/dev/null 2>&1; then
    terraform version
    exit 0
  fi
  apt-get update -q
  apt-get install -y wget unzip
  wget -q https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
  unzip -o terraform_1.7.0_linux_amd64.zip
  mv terraform /usr/local/bin/
  rm terraform_1.7.0_linux_amd64.zip
  terraform version
'

echo "Terraform installe dans Jenkins."
