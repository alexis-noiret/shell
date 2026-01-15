#!/bin/bash
# Vérification du nombre d'arguments
if [ "$#" -ne 3 ]; then
    echo "Usage : ./my_calculator.sh nombre1 opérateur nombre2"
    exit 1
fi
# Récupération des arguments
a="$1"
op="$2"
b="$3"
# Calcul selon l'opérateur
case "$op" in
    +)
        result=$((a + b))
        ;;
    -)
        result=$((a - b))
        ;;
    x|\*)
        result=$((a * b))
        ;;
    /|÷)
        if [ "$b" -eq 0 ]; then
            echo "Erreur : division par zéro"
            exit 1
        fi
        result=$((a / b))
        ;;
    *)
        echo "Opérateur invalide. Utilisez + - x ÷"
        exit 1
        ;;
esac
# Affichage du résultat
echo "Résultat : $result"

