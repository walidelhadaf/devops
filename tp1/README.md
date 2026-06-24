# TP1 — SentimentAI

API REST d'analyse de sentiments pour StartupIA (Git & Docker).

## Description

SentimentAI est une API FastAPI qui reçoit un texte en entrée, l'analyse et retourne un label (`POSITIVE`, `NEGATIVE` ou `NEUTRAL`) accompagné d'un score de confiance entre 0 et 1.

## Démarrage rapide

```bash
# Construire l'image Docker
make build

# Lancer la stack
make run

# Lancer les tests
make test

# Arrêter la stack
make stop
```

## Endpoints

- `GET /health` — Healthcheck
- `POST /predict` — Analyse de sentiment

```bash
curl -X POST http://localhost:8080/predict \
  -H "Content-Type: application/json" \
  -d '{"text": "Ce produit est excellent !"}'
```

## Version

v0.1.0
