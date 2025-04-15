# 🍔 FoodFast - Livraison de repas express

## Stack Technique
- Node.js + PostgreSQL
- Docker, Kubernetes (EKS)
- Terraform (IaC)
- GitLab CI/CD + ArgoCD
- Prometheus + Grafana
- SonarQube + Trivy

## Déploiement CI/CD
1. Docker build
2. Tests avec Jest
3. Scan vulnérabilités (Trivy) & qualité (SonarQube)
4. Push vers ECR
5. Déploiement automatique via ArgoCD

## Monitoring
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus
helm install grafana grafana/grafana --set adminPassword='admin' --set service.type=LoadBalancer
```

## Lancement Terraform
```bash
cd terraform
terraform init
terraform apply
```

## Lancement Local
```bash
docker build -t foodfast .
docker run -p 3000:3000 foodfast
```
