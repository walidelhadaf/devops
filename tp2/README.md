# TP2 — Jenkins Pipeline

Pipeline CI/CD pour SentimentAI avec Jenkins, Docker et GitHub Packages.

## Structure

| Fichier | Rôle |
|---------|------|
| `docker-compose.yml` | Lance Jenkins (port **8080**) |
| `setup.sh` | Installe Docker dans Jenkins + affiche le mot de passe initial |
| `../tp1/Jenkinsfile` | Pipeline Groovy (4 stages) |

> **Note port** : SentimentAI (TP1) utilise le port **8081** pour éviter le conflit avec Jenkins sur **8080**.

## 1. Démarrer Jenkins

```bash
cd tp2
chmod +x setup.sh
./setup.sh
```

Ouvrir http://localhost:8080 et suivre l'assistant :
1. Coller le mot de passe initial affiché par `setup.sh`
2. **Install suggested plugins**
3. Créer le compte admin
4. Installer : **Docker Pipeline**, **Git**, **Pipeline**, **Blue Ocean**

## 2. Configurer les credentials GitHub

1. GitHub → Settings → Developer settings → Personal access tokens → **Tokens (classic)**
2. Cocher : `repo`, `read:packages`, `write:packages`
3. Jenkins → Credentials → Global → Add :
   - Kind : **Username with password**
   - Username : `walidelhadaf`
   - Password : le token GitHub
   - ID : `github-token`

## 3. Créer le job Pipeline

1. **Nouveau Item** → `sentiment-ai-pipeline` → **Pipeline**
2. **GitHub project** : `https://github.com/walidelhadaf/devops`
3. **Build Triggers** : Poll SCM → `H/5 * * * *`
4. **Pipeline** :
   - Definition : **Pipeline script from SCM**
   - SCM : Git
   - Repository URL : `https://github.com/walidelhadaf/devops.git`
   - Credentials : `github-token`
   - Branch : `*/main`
   - **Script Path** : `tp1/Jenkinsfile`
5. **Save** → **Build Now**

## 4. Stages du pipeline

| Stage | Action |
|-------|--------|
| **Checkout** | Clone le repo Git |
| **Lint** | flake8 sur `tp1/src/` |
| **Build & Test** | `docker build` + pytest (coverage ≥ 70%) |
| **Push** | Push vers `ghcr.io/walidelhadaf/sentiment-ai` (main uniquement) |

## 5. Webhook (optionnel)

Si ngrok est disponible :

```bash
ngrok http 8080
```

GitHub → Settings → Webhooks → URL : `https://VOTRE_URL.ngrok.io/github-webhook/`

Jenkins → job → cocher **GitHub hook trigger for GITScm polling**

## Commandes utiles

```bash
make jenkins-up      # depuis tp2/
make jenkins-down
make jenkins-logs
make jenkins-password
```

## Réponses aux questions

**Q1.1 — Volume `jenkins-data`**  
Il persiste les jobs, builds, plugins et credentials Jenkins dans `/var/jenkins_home`, même si le conteneur est recréé.

**Q1.2 — `/var/run/docker.sock`**  
Il permet à Jenkins d'utiliser le Docker de l'hôte (DooD). Risque : accès root à la machine via le socket. En production : agent Docker dédié, socket restreint, ou Kaniko/BuildKit sans DooD.

**Q2.1 — `post { always }`**  
Nettoie les ressources quel que soit le résultat. `|| true` évite qu'un échec de cleanup fasse échouer le pipeline.

**Q2.2 — `agent any` vs agent Docker**  
`agent any` utilise n'importe quel agent Jenkins. Un agent Docker isole l'environnement d'exécution dans une image dédiée (ex. Python 3.11).

**Q2.3 — `when { branch 'main' }`**  
Évite de polluer le registry avec des images non validées depuis des branches feature.

**Q4.1 — Poll SCM vs Webhook**  
Poll SCM vérifie périodiquement (délai jusqu'à 5 min, charge CPU). Webhook = déclenchement instantané à chaque push, sans polling.
