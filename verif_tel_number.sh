#!/bin/bash

# Vérifier qu'un argument est fourni
if [ "$#" -ne 1 ]; then
    echo "Usage : ./verif_tel_number.sh numero"
    exit 1
fi

PHONE="$1"

# Regex numéro français
REGEX="^(\+33|0)[1-9][0-9]{8}$"

if [[ "$PHONE" =~ $REGEX ]]; then
    echo "Numéro correct"
else
    echo "Mauvais format"
fi
