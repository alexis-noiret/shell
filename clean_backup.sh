#!/bin/bash

BACKUP_DIR="$HOME/Backup"

# Vérifie que le dossier existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Le dossier $BACKUP_DIR n'existe pas."
    exit 1
fi

# Supprime tous les fichiers .tar sauf les 5 plus récents
ls -t "$BACKUP_DIR"/*.tar 2>/dev/null | tail -n +6 | xargs -r rm --
