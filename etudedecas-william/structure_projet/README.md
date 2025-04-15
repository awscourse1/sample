# FoodFast DevOps Project

Ce référentiel contient l'infrastructure en tant que code et les configurations CI/CD pour l'application de livraison de repas FoodFast.

## À propos du projet

FoodFast est une startup spécialisée dans la livraison de repas qui développe une application web en Node.js avec une base de données PostgreSQL. Ce projet implémente une chaîne CI/CD complète pour automatiser le déploiement et les tests, garantir un déploiement fiable sur AWS EKS, et intégrer des outils de qualité de code et de supervision.

## Architecture

L'architecture cloud-native AWS comprend :
- VPC avec sous-réseaux publics et privés
- Cluster EKS pour l'orchestration des conteneurs
- Base de données PostgreSQL sur RDS
- ECR pour le stockage des images Docker
- CI/CD via GitLab et ArgoCD
- Supervision avec Prometheus et Grafana

## Prérequis

- AWS CLI configuré avec les autorisations appropriées
- Terraform v1.5+
- kubectl
- Docker
- Accès à GitLab
- Helm v3+

## Liste des outils utilisés

| Catégorie | Outils |
|-----------|--------|
| **IaC** | Terraform |
| **Conteneurisation** | Docker |
| **Orchestration** | Kubernetes (EKS) |
| **CI/CD** | GitLab CI/CD, ArgoCD |
| **Qualité de code** | SonarQube |
| **Sécurité** | Trivy |
| **Surveillance** | Prometheus, Grafana |
| **Base de données** | PostgreSQL (AWS RDS) |
| **Registre d'images** | Amazon ECR |
| **Infrastructure Cloud** | AWS (VPC, EKS, RDS, ECR, ALB) |

## Étapes de déploiement

### 1. Configurer l'accès AWS

```bash
aws configure
```

### 2. Provisionner l'infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

### 3. Configurer kubectl pour l'accès au cluster EKS

```bash
aws eks update-kubeconfig --name foodfast-dev --region eu-west-3
```

### 4. Installer ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Récupérer le mot de passe admin initial
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 5. Installer Prometheus et Grafana

```bash
# Ajouter le repo Helm pour Prometheus et Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Créer un namespace pour la supervision
kubectl create namespace monitoring

# Installer Prometheus avec le Helm chart
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.persistentVolume.storageClass="gp2" \
  --set server.persistentVolume.storageClass="gp2"

# Installer Grafana avec le Helm chart
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.storageClassName="gp2" \
  --set persistence.enabled=true \
  --set adminPassword='foodFastAdmin!' \
  --values - <<EOF
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local
      access: proxy
      isDefault: true
EOF

# Exposer Grafana via un Service de type LoadBalancer
kubectl patch svc grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

# Récupérer l'URL de Grafana
kubectl get svc -n monitoring grafana -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

# Récupérer le mot de passe admin de Grafana
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

### 6. Configurer le pipeline CI/CD dans GitLab

1. Créer un nouveau projet GitLab
2. Ajouter les variables d'environnement suivantes dans les paramètres CI/CD du projet :
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`
   - `ARGOCD_USERNAME`
   - `ARGOCD_PASSWORD`
3. Pousser le code vers le dépôt GitLab pour déclencher le pipeline

## Environnements

Le projet prend en charge plusieurs environnements :

- **dev** : Pour le développement et les tests
- **staging** : Pour les tests d'intégration
- **prod** : Pour la production

Chaque environnement est isolé avec ses propres ressources AWS.

## Pipeline CI/CD

Le pipeline GitLab CI/CD comprend les étapes suivantes :

1. **test** : Exécution des tests unitaires et d'intégration
2. **build** : Construction de l'image Docker de l'application
3. **quality** : Analyse de la qualité du code avec SonarQube
4. **security** : Scan des vulnérabilités avec Trivy
5. **push** : Publication de l'image Docker dans ECR
6. **deploy** : Déploiement sur EKS via ArgoCD

## Surveillance

La stack de supervision inclut :
- **Prometheus** : Collecte des métriques
- **Grafana** : Visualisation des métriques avec des dashboards préconfigurés

Pour accéder à Grafana :
```bash
export GRAFANA_URL=$(kubectl get svc -n monitoring grafana -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
echo "Accédez à Grafana via: http://$GRAFANA_URL"
```

## Bonnes pratiques de sécurité

- Segmentation du réseau avec des sous-réseaux publics et privés
- Données sensibles stockées dans des secrets Kubernetes ou AWS Secrets Manager
- Communications entre services chiffrées
- Scans de sécurité automatisés dans le pipeline CI/CD
- Contrôle d'accès basé sur les rôles (RBAC) pour Kubernetes
- Mise à jour régulière des images et des dépendances

## Maintenance

- **Sauvegardes** : RDS est configuré avec des sauvegardes automatiques quotidiennes
- **Journalisation** : Tous les logs sont centralisés dans CloudWatch
- **Mises à jour** : Des fenêtres de maintenance sont configurées pour les mises à jour automatiques de la base de données

## Dépannage

### Problèmes courants

1. **Échec du déploiement sur EKS** :
   ```bash
   kubectl get pods -n foodfast-dev
   kubectl describe pod <pod-name> -n foodfast-dev
   kubectl logs <pod-name> -n foodfast-dev
   ```

2. **Problèmes de connexion à la base de données** :
   Vérifiez que les groupes de sécurité permettent la connexion depuis EKS vers RDS.

3. **Pipeline CI/CD échoue** :
   Vérifiez les logs dans GitLab et assurez-vous que toutes les variables d'environnement sont correctement configurées.

