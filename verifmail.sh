#!/bin/bash

# Vérifier qu'un argument est fourni
if [ "$#" -ne 1 ]; then
    echo "Usage : ./verifmail.sh adresse_email"
    exit 1
fi

EMAIL="$1"

# Regex pour une adresse mail valide
REGEX="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

if [[ "$EMAIL" =~ $REGEX ]]; then
    echo "Adresse correcte"
else
    echo "Mauvais format"
fi
