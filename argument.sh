#!/bin/bash

# Vérification du nombre d'arguments
if [ $# -ne 2 ]; then
    echo "Usage : $0 <nouveau_fichier> <fichier_source>"
    exit 1
fi

nouveau_fichier="$1"
fichier_source="$2"

# Vérification que le fichier source existe
if [ ! -f "$fichier_source" ]; then
    echo "Erreur : le fichier source '$fichier_source' n'existe pas."
    exit 1
fi

# Copie du contenu
cat "$fichier_source" > "$nouveau_fichier"

echo "Le contenu de '$fichier_source' a été copié dans '$nouveau_fichier'."

