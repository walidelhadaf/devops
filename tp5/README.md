# TP5 — Monitoring Prometheus & Grafana

Observabilite de SentimentAI : metriques, Prometheus, Grafana, smoke test Jenkins.

## 1. Metriques FastAPI

L'API expose `GET /metrics` avec :
- `sentiment_predictions_total` (Counter)
- `sentiment_confidence_score` (Gauge)
- `sentiment_prediction_duration_seconds` (Histogram)
- Metriques HTTP automatiques (Instrumentator)

```bash
curl -s http://localhost:8001/metrics | grep sentiment
```

## 2. Demarrer Prometheus + Grafana

```bash
cd tp5
chmod +x setup.sh
./setup.sh
```

Ou via Terraform (inclus dans `tp1/infra/monitoring.tf`) :
```bash
cd tp1/infra
export TF_VAR_docker_host="unix://$HOME/.docker/run/docker.sock"
terraform apply -auto-approve -var='image_tag=latest'
```

| Service | URL | Login |
|---------|-----|-------|
| Prometheus | http://localhost:9090 | — |
| Grafana | http://localhost:3000 | admin / admin |
| SentimentAI staging | http://localhost:8001 | — |

## 3. Configurer Grafana

1. http://localhost:3000 → admin / admin
2. **Connections → Data sources → Prometheus**
3. URL : **`http://prometheus:9090`** (pas localhost)
4. **Save & Test**

## 4. Dashboard — 4 panels

| Panel | Type | PromQL |
|-------|------|--------|
| Requetes/s | Time series | `rate(http_requests_total{handler="/predict"}[1m])` |
| Latence p99 | Time series | `histogram_quantile(0.99, rate(sentiment_prediction_duration_seconds_bucket[5m]))` |
| Taux erreurs | Stat | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100` |
| Confiance | Gauge | `avg(sentiment_confidence_score)` |

Generer du trafic :
```bash
for i in $(seq 1 50); do
  curl -s -X POST http://localhost:8001/predict \
    -H "Content-Type: application/json" \
    -d '{"text": "Ce produit est vraiment bien"}' > /dev/null
  sleep 0.5
done
```

## 5. Pipeline Jenkins — 11 stages

Ajout du stage **Smoke Test** apres Deploy Staging.

Jenkins → **Build Now**

## Reponses aux questions

**Q1.2** — Counter = valeur qui augmente (predictions_total). Gauge = valeur qui monte/descend (confidence_score).

**Q2.3** — `sentiment-staging:8000` utilise le DNS Docker sur le reseau partage, pas localhost.

**Q3.2** — `histogram_quantile(0.99, ...)` calcule un vrai percentile ; `avg()` masque les pics de latence.

**Q4.2** — Attendre 20s laisse Prometheus faire au moins 1 scrape (intervalle 15s).
