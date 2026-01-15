#!/bin/bash
#!/usr/bin/env bash
set -e
[ $# -ge 1 ] || { echo "Usage: $0 email [password]"; exit 1; }
U="$1"; P="${2:-}"; [ -n "$P" ] || { read -rsp "Mot de passe Alcasar: " P; echo; }
HOST="alcasar.laplateforme.io"; J="$(mktemp)"; trap 'rm -f "$J"' EXIT
URL="$(curl -sL -o /dev/null -w '%{url_effective}' http://www.gstatic.com/generate_204)"; [[ "$URL" == *"$HOST"* ]] || { echo "Pas de portail captif (pas de redirection)."; exit 2; }
PAGE="$(curl -sL -c "$J" -b "$J" "$URL")"
CHAL="$(echo "$PAGE" | grep -oP 'name="challenge"\s+value="\K[^"]+' | head -1)"
UURL="$(echo "$PAGE" | grep -oP 'name="userurl"\s+value="\K[^"]+' | head -1)"
curl -sL -b "$J" -c "$J" --data-urlencode "challenge=$CHAL" --data-urlencode "userurl=$UURL" --data-urlencode "username=$U" --data-urlencode "password=$P" --data-urlencode "button=Authentication" "https://$HOST/intercept.php" >/dev/null
curl -sk "https://$HOST:3991/json/status?callback=x&0.$RANDOM" | grep -q '"clientState":1' && echo "Connecté !" || echo "Échec"

