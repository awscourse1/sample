# Mettre à jour les paquets
sudo apt update
sudo apt upgrade -y

# Installer les dépendances
sudo apt install -y apt-transport-https software-properties-common wget

# Installer Prometheus
## Créer l'utilisateur Prometheus
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

## Créer les répertoires
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

## Télécharger Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
tar xvf prometheus-2.43.0.linux-amd64.tar.gz

## Copier les fichiers
sudo cp prometheus-2.43.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.43.0.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.43.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.43.0.linux-amd64/console_libraries /etc/prometheus

## Créer le fichier de configuration
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
EOF

## Configurer le service systemd pour Prometheus
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

## Définir les permissions
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chmod -R 775 /etc/prometheus /var/lib/prometheus

## Démarrer Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Installer Grafana
## Ajouter le référentiel APT de Grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

## Installer Grafana
sudo apt update
sudo apt install -y grafana

## Démarrer Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Vérifier l'état des services
echo "État de Prometheus:"
sudo systemctl status prometheus
echo "État de Grafana:"
sudo systemctl status grafana-server
