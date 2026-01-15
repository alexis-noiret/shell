#!/bin/bash

# Vérifier que 2 arguments sont fournis
if [ "$#" -ne 2 ]; then
    echo "Usage : ./add.sh nombre1 nombre2"
    exit 1
fi

# Addition des deux nombres
result=$(( $1 + $2 ))

# Affichage du résultat
echo "Résultat : $result"
