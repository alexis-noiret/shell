#!/bin/bash

# Vérifier qu'un argument est fourni
if [ "$#" -ne 1 ]; then
    echo "Usage : ./hello_bye.sh Hello|Bye"
    exit 1
fi

# Condition selon l'argument
if [ "$1" = "Hello" ]; then
    echo "Bonjour, je suis un script !"
elif [ "$1" = "Bye" ]; then
    echo "Au revoir et bonne journée !"
else
    echo "Argument invalide. Utilisez Hello ou Bye."
fi
