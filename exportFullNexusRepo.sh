#!/bin/bash

# Définition des paramètres Nexus
NEXUS_URL="http://votre-nexus-url:8081"
REPOSITORY_NAME="nom-du-repository"
REPOSITORY_URL="$NEXUS_URL/repository/$REPOSITORY_NAME"
USERNAME="votre-username"
PASSWORD="votre-password"

# Création d'un répertoire temporaire pour stocker les fichiers téléchargés
TEMP_DIR=$(mktemp -d)

# Téléchargement du repository complet
curl -u $USERNAME:$PASSWORD -X GET $REPOSITORY_URL -o $TEMP_DIR/$REPOSITORY_NAME.zip

# Décompression du fichier téléchargé
unzip $TEMP_DIR/$REPOSITORY_NAME.zip -d $TEMP_DIR

# Suppression du fichier zip
rm $TEMP_DIR/$REPOSITORY_NAME.zip

# Affichage de la confirmation
echo "Le repository complet a été téléchargé dans le répertoire temporaire : $TEMP_DIR"
