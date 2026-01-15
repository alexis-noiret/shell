#!/bin/bash

CSV_FILE="/home/laplateforme/Shell_Userlist.csv"
TIMESTAMP_FILE="/home/laplateforme/.csv_last_modified"

CURRENT_MODIF=$(stat -c %Y "$CSV_FILE")

# Si le fichier timestamp n'existe pas, on le crée et on lance le script
if [ ! -f "$TIMESTAMP_FILE" ]; then
    echo "$CURRENT_MODIF" > "$TIMESTAMP_FILE"
    sudo /home/laplateforme/accessrights.sh
    exit 0
fi

LAST_MODIF=$(cat "$TIMESTAMP_FILE")

# Si la date a changé, on met à jour le fichier timestamp et on relance le script
if [ "$CURRENT_MODIF" != "$LAST_MODIF" ]; then
    echo "$CURRENT_MODIF" > "$TIMESTAMP_FILE"
    sudo /home/laplateforme/accessrights.sh
fi
