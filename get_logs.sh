#!/bin/bash

USER="laplateforme"
DATE=$(date '+%d-%m-%Y-%H-%M')   
BACKUP_DIR="$HOME/Backup"

# Créer le dossier Backup si il n'existe pas
mkdir -p "$BACKUP_DIR"

# Compter les connexions de l'utilisateur
CONNECTIONS=$(last | grep "^$USER" | wc -l)

# Nom du fichier
FILE_NAME="number_connection-$DATE"

# Écrire le nombre de connexions
echo "$CONNECTIONS" > "$FILE_NAME"

# Archiver le fichier
tar -cf "$FILE_NAME.tar" "$FILE_NAME"

# Déplacer l'archive dans Backup
mv "$FILE_NAME.tar" "$BACKUP_DIR/"

# Supprimer le fichier original
rm "$FILE_NAME"

