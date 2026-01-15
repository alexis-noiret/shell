#!/bin/bash

CSV_FILE="/home/laplateforme/Shell_Userlist.csv"
HASH_FILE="/var/tmp/shell_userlist.hash"

# Vérifier que le fichier CSV existe
if [ ! -f "$CSV_FILE" ]; then
    echo "Fichier CSV introuvable"
    exit 1
fi

# Calcul du hash actuel du CSV
CURRENT_HASH=$(sha256sum "$CSV_FILE" | awk '{print $1}')

# Vérifier si le fichier a changé
if [ -f "$HASH_FILE" ]; then
    OLD_HASH=$(cat "$HASH_FILE")
    if [ "$CURRENT_HASH" = "$OLD_HASH" ]; then
        echo "Aucun changement détecté dans le CSV"
        exit 0
    fi
fi

echo "Changement détecté – synchronisation des utilisateurs..."

# Lecture du CSV (sans l'en-tête)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r ID PRENOM NOM MDP ROLE
do
    # Nettoyage (espaces + retours Windows)
    PRENOM=$(echo "$PRENOM" | tr -d '\r' | xargs)
    NOM=$(echo "$NOM" | tr -d '\r' | xargs)
    MDP=$(echo "$MDP" | tr -d '\r' | xargs)
    ROLE=$(echo "$ROLE" | tr -d '\r' | xargs)

    # Création du nom d'utilisateur (prenom.nom en minuscules)
    USERNAME="$(echo "${PRENOM}.${NOM}" | tr '[:upper:]' '[:lower:]')"

    # Création de l'utilisateur s'il n'existe pas
    if ! id "$USERNAME" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$USERNAME"
        echo "$USERNAME:$MDP" | sudo chpasswd
        echo "Utilisateur $USERNAME créé"
    else
        echo "Utilisateur $USERNAME existe déjà"
    fi

    # Gestion des droits admin (insensible à la casse)
    if [[ "${ROLE,,}" == "admin" ]]; then
        sudo usermod -aG sudo "$USERNAME"
        echo "$USERNAME ajouté au groupe sudo"
    fi
done

# Sauvegarde du hash actuel
echo "$CURRENT_HASH" > "$HASH_FILE"

echo "Synchronisation terminée"

