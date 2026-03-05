# 🚀 Projet Fil Rouge : Stack DevSecOps Automatisée

Ce dépôt contient l'automatisation complète de l'infrastructure et du déploiement pour une application web (Symfony/Vue.js) sur AWS. 

## 🏗️ Architecture Cloud (Terraform)
L'infrastructure est déployée dans la région **Paris (eu-west-3)** et comprend :
- **Réseau :** Un VPC (10.0.0.0/16) avec un sous-réseau public, une Gateway Internet et une table de routage.
- **Sécurité :** Security Groups autorisant le SSH (22) pour l'administration et le HTTP (80) pour le web.
- **Instances EC2 :** 3 serveurs de type `t3.micro` éligibles au Free Tier :
  - `server-dev` : Environnement de développement.
  - `server-test` : Environnement de test et de validation.
  - `server-prod` : Environnement de production.

## 🛠️ Outils utilisés
- **Infrastructure as Code :** Terraform
- **Configuration & Déploiement :** Ansible
- **Versionning :** Git & GitHub
- **Cloud :** AWS (EC2, VPC, Security Groups)-
- **Conteneurisation :** Docker & Docker Compose
- **Base de données :** PostgreSQL
- **Sécurité :** Ansible Vault, UFW (Uncomplicated Firewall), Chekov, Ansible-lint, GitLeak


## 🚦 Guide de démarrage rapide

### 1. Prérequis
- Avoir installé Terraform et AWS CLI sur sa machine locale.
- Avoir configuré ses accès AWS (`aws configure`).
- Avoir généré une paire de clés SSH (`ssh-keygen`).

### 2. Déploiement de l'infrastructure
```bash
cd terraform
terraform init
terraform apply
```
Note : Les adresses IP sont récupérées via les outputs de Terraform.

### 3. Configuration avec Ansible
Mettre à jour les adresses IP dans ansible/inventory.ini.

Tester la connexion (Ping) :
```bash
cd ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible all -i inventory.ini -m ping
```

## 📂 Structure du projet

- /terraform : Configuration de l'infrastructure.
- /ansible : Inventaire des serveurs

## 🔐 Gestion des Secrets (Ansible Vault)
Les variables sensibles (mots de passe DB) sont stockées dans `ansible/vars/secrets.yml` et sont chiffrées avec **Ansible Vault**.

Pour modifier les secrets :
````ansible-vault edit ansible/vars/secrets.yml````

## 🐘 Base de données
Le déploiement de PostgreSQL se fait via Docker.

Commande pour installer docker :
````ansible-playbook -i inventory.ini setup-docker.yml````

Commande pour lancer le déploiement :
````ansible-playbook -i inventory.ini deploy-db.yml --ask-vault-pass````

## 🧱 Activation du Pare-feu (UFW) :
Sécurisation de l'OS tout en maintenant l'accès SSH, HTTP et BDD.
````ansible -i inventory.ini all -m shell -a "sudo ufw allow 22/tcp && sudo ufw allow 80/tcp && sudo ufw allow 5432/tcp && sudo ufw --force enable"````

## 🧪 Tests de connectivité
Pour valider que le serveur de Test communique bien avec le serveur de Dev via le réseau privé AWS (port 5432) :

````ansible-playbook -i inventory.ini test-connection.yml````

## 🛡️ Qualité & Sécurité (Checkov, Ansible-Lint, Gitleaks)

- **Chekov** : Scan de l'Infrastructure-as-Code (Terraform)
```` docker run --rm -v $(pwd):/tf bridgecrew/checkov -d /tf ````

- **Ansible-Lint** : Validation des bonnes pratiques d'automatisation.
```` docker run --rm -v $(pwd):/data -w /data cytopia/ansible-lint ansible/ ````

- **Gitleaks** : Détection de secrets (clés AWS, mots de passe) avant le commit.
```` docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect --source="/path" -v ````

Note: Initialement envisagé pour ce projet, l'outil Trivy n'a pas pu être utilisé suite à un incident de sécurité majeur ayant impacté ses dépôts officiels. Par mesure de précaution et pour garantir l'intégrité de notre pipeline DevSecOps, nous avons pivoté vers Checkov et Gitleaks.