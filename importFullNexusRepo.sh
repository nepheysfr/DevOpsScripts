#!/bin/bash

# Définition des paramètres Nexus
USERNAME="votre-username"
PASSWORD="votre-password"
TARGET_NEXUS_URL="http://nouvelle-nexus-url:8081"
TARGET_REPOSITORY_NAME="nom-du-nouveau-repository"
TARGET_REPOSITORY_URL="$TARGET_NEXUS_URL/repository/$TARGET_REPOSITORY_NAME"

# Création d'un répertoire temporaire pour stocker les fichiers téléchargés
TEMP_DIR=$(mktemp -d)

# Déploiement des artefacts vers le repository cible
curl -v -u $USERNAME:$PASSWORD --upload-file $TEMP_DIR/* $TARGET_REPOSITORY_URL

# Affichage de la confirmation
echo "Les artefacts ont été déployés vers le nouveau repository : $TARGET_REPOSITORY_URL"

# Nettoyage du répertoire temporaire
rm -rf $TEMP_DIR
