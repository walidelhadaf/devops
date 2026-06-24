variable "image_tag" {
  description = "Tag de l'image Docker a deployer"
  type        = string
  default     = "latest"
}

variable "app_port" {
  description = "Port expose en staging (8080 reserve a Jenkins)"
  type        = number
  default     = 8001
}

variable "container_name" {
  description = "Nom du conteneur staging"
  type        = string
  default     = "sentiment-staging"
}

variable "registry" {
  description = "Registry Docker (reference documentation)"
  type        = string
  default     = "ghcr.io/walidelhadaf"
}

variable "network_name" {
  description = "Reseau Docker partage avec Jenkins et SonarQube"
  type        = string
  default     = "tp2_cicd-network"
}

variable "docker_host" {
  description = "Socket Docker (Linux par defaut, adapter sur macOS)"
  type        = string
  default     = "unix:///var/run/docker.sock"
}
