#!/bin/bash
# install.sh
# Script principal d'installation de Prometheus et Grafana pour FoodFast

set -e
echo "Installation de Prometheus et Grafana en local pour FoodFast"

# Création des répertoires nécessaires
echo "Création des répertoires..."
mkdir -p ~/foodfast-monitoring/prometheus
mkdir -p ~/foodfast-monitoring/grafana/data
mkdir -p ~/foodfast-monitoring/grafana/provisioning/datasources
mkdir -p ~/foodfast-monitoring/grafana/provisioning/dashboards

# Copie des fichiers de configuration
echo "Copie des fichiers de configuration..."
cp ./configs/prometheus.yml ~/foodfast-monitoring/prometheus/
cp ./configs/datasources.yml ~/foodfast-monitoring/grafana/provisioning/datasources/
cp ./configs/dashboards.yml ~/foodfast-monitoring/grafana/provisioning/dashboards/
cp ./configs/nodejs-dashboard.json ~/foodfast-monitoring/grafana/provisioning/dashboards/
cp ./docker-compose.yml ~/foodfast-monitoring/

# Lancement des conteneurs
echo "Démarrage de Prometheus et Grafana..."
cd ~/foodfast-monitoring
docker-compose up -d

# Attendre que les services démarrent
echo "Attente du démarrage des services..."
sleep 10

echo "============================================="
echo "🎉 Installation terminée avec succès! 🎉"
echo "============================================="
echo ""
echo "Prometheus est accessible à l'adresse: http://localhost:9090"
echo "Grafana est accessible à l'adresse:    http://localhost:3001"
echo "  - Nom d'utilisateur: admin"
echo "  - Mot de passe: admin"
echo ""
echo "Pour arrêter les services:"
echo "  cd ~/foodfast-monitoring && docker-compose down"
echo ""
echo "Assurez-vous que votre application Node.js expose ses métriques sur /metrics"
echo "et qu'elle est configurée pour utiliser prom-client comme montré dans la documentation."
echo "============================================="