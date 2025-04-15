# FoodFast DevOps Project

Ce dépôt contient l'infrastructure et les configurations CI/CD pour l'application FoodFast de livraison de repas.

## Architecture

L'application FoodFast est déployée sur AWS avec une architecture cloud-native :

* **Application** : Node.js avec Express, conteneurisée avec Docker
* **Base de données** : PostgreSQL sur AWS RDS
* **Orchestration** : Kubernetes sur AWS EKS
* **CI/CD** : GitLab CI/CD + ArgoCD
* **Qualité & Sécurité** : SonarQube + Trivy
* **Monitoring** : Prometheus + Grafana
* **Infrastructure as Code** : Terraform

## Prérequis

* [AWS CLI](https://aws.amazon.com/cli/) installé et configuré
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installé
* [Terraform](https://www.terraform.io/downloads.html) installé
* [Docker](https://docs.docker.com/get-docker/) installé
* [Git](https://git-scm.com/downloads) installé
* Accès à un compte GitLab

## Structure du projet

```
foodfast/
├── .gitlab-ci.yml           # Configuration pipeline GitLab CI/CD
├── README.md                # Documentation du projet
├── docker/                  # Fichiers Docker
│   ├── Dockerfile           # Image de l'application
│   └── docker-compose.yml   # Configuration pour le développement local
├── terraform/          # Terraform
│   ├── main.tf              # Point d'entrée Terraform
│   ├── modules/             # Modules Terraform
│   │   ├── vpc/             # Module VPC
│   │   ├── eks/             # Module EKS
│   │   ├── rds/             # Module RDS
│   │   └── ecr/             # Module ECR
│   ├── variables.tf         # Variables Terraform
│   └── outputs.tf           # Sorties Terraform
├── k8s/                     # Kubernetes
│   ├── deployment.yaml      # Déploiement de l'application
│   ├── service.yaml         # Service Kubernetes
│   ├── ingress.yaml         # Ingress pour l'exposition de l'API
│   └── configmap.yaml       # ConfigMap pour configurations
├── src/                     # Code source de l'application Node.js
├── tests/                   # Tests unitaires et d'intégration
├── monitoring/              # Configuration de monitoring configs/
│   ├── configs /            # Configs
│   │   ├── prometheus/      # Configuration Prometheus
│   │   └── grafana/         # Configuration Grafana
│   └── dashboard.json       # Template dashboard Node
└── sonar-project.properties # Configuration SonarQube
```

## Guide de démarrage

### 1. Configuration de l'infrastructure AWS

```bash
# Initialiser Terraform
cd infrastructure/
terraform init

# Planifier les changements
terraform plan -out=tfplan

# Appliquer les changements
terraform apply tfplan
```

### 2. Configurer GitLab CI/CD

1. Dans les paramètres GitLab du projet, ajoutez les variables suivantes :
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `ECR_REPOSITORY_URL` (URL du repository ECR créé par Terraform)
   - `KUBE_CONFIG_PATH` (encodé en base64)
   - `POSTGRES_HOST` (endpoint RDS)
   - `POSTGRES_USER`
   - `POSTGRES_PASSWORD`
   - `POSTGRES_DB`
   - `GITOPS_ACCESS_TOKEN` (token GitLab pour accéder au dépôt GitOps)
   - `ARGOCD_SERVER`
   - `ARGOCD_USERNAME`
   - `ARGOCD_PASSWORD`

2. Configurez la clé SSH pour l'accès au dépôt GitOps (si nécessaire)

### 3. Installation d'ArgoCD

```bash
# Création du namespace ArgoCD
kubectl create namespace argocd

# Installation d'ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Exposer l'API ArgoCD (pour production, utilisez un Ingress)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Obtenir le mot de passe initial d'admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Déploiement de la surveillance

```bash
# Exécuter le script d'installation de Prometheus et Grafana
chmod +x monitoring/installer-monitoring.sh
./monitoring/installer-monitoring.sh
```

### 5. Lancer le pipeline CI/CD

Poussez le code sur GitLab pour déclencher le pipeline CI/CD.

```bash
git push origin main
```

## Utilisation locale pour le développement

```bash
# Démarrer l'environnement de développement local
cd docker/
docker-compose up -d

# Accéder à l'application
open http://localhost:3000
```

## Monitoring

Une fois déployé, vous pouvez accéder aux interfaces de monitoring :

* **Grafana** : http://[GRAFANA_URL] (par défaut, admin/strongPassword)
* **Prometheus** : http://[PROMETHEUS_URL]
* **ArgoCD** : http://[ARGOCD_URL] (utilisez le mot de passe récupéré plus haut)

## Déploiement dans un nouvel environnement

Pour déployer l'application dans un nouvel environnement (staging, production) :

1. Créez un nouveau workspace Terraform
   ```bash
   cd infrastructure/
   terraform workspace new production
   ```

2. Configurez les variables spécifiques à l'environnement
   ```bash
   cp terraform.tfvars.example terraform.tfvars.production
   # Modifiez les valeurs selon vos besoins
   ```

3. Appliquez la configuration
   ```bash
   terraform apply -var-file=terraform.tfvars.production
   ```

4. Mettez à jour les variables GitLab CI/CD pour le nouvel environnement