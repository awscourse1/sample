#!/bin/bash

# Mise à jour du système
apt update

# Installation de nginx
apt install -y nginx

# Démarrage et activation de nginx
systemctl start nginx
systemctl enable nginx