#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template.html"
OUTPUT="$SCRIPT_DIR/index.html"


export LC_ALL=C
export LC_NUMERIC=C


# --- Helpers ---

usage_class() {
    local v=${1/,/.}   # , -> .
    v=${v%.*}          # garde l'entier
    v=${v:-0}          # fallback si vide

    if (( v <= 50 )); then echo "usage-vert"
    elif (( v <= 80 )); then echo "usage-orange"
    else echo "usage-rouge"
    fi
}

# --- System info ---

HOSTNAME=$(hostname)
OS_NAME="$(uname -s) $(uname -r)"
BOOT_TIME=$(who -b | awk '{print $3" "$4}')
UPTIME=$(uptime -p | sed 's/up //')
USER_COUNT=$(who | wc -l)
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# --- CPU info ---

CPU_CORES=$(nproc)
CPU_FREQ=$(awk -F ': ' '/cpu MHz/ {print $2; exit}' /proc/cpuinfo)
CPU_USAGE=$(top -bn1 | awk '/Cpu/ {print 100-$8}')
CPU_USAGE_INT=${CPU_USAGE%.*}
CPU_USAGE_HTML="<span class=\"$(usage_class $CPU_USAGE_INT)\">$CPU_USAGE_INT%</span>"

read LOAD1 LOAD5 LOAD15 < /proc/loadavg

CPU_PER_CORE_HTML=""
core=0
for usage in $(mpstat -P ALL 1 1 | awk '/Average:/ && $2 ~ /^[0-9]+$/ {print 100-$12}'); do
    ((core++))
    class=$(usage_class ${usage%.*})
    CPU_PER_CORE_HTML+="<li>Core $core: <span class=\"$class\">${usage%.*}%</span></li>"
done

# --- RAM info ---

TOTAL_RAM=$(free -m | awk '/Mem:/ {printf "%.2f", $2/1024}')
USED_RAM=$(free -m | awk '/Mem:/ {printf "%.2f", $3/1024}')
RAM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
RAM_USAGE_HTML="<span class=\"$(usage_class $RAM_USAGE)\">$RAM_USAGE%</span>"

############################################
# --- Alerte CPU / RAM + Envoi de mail ---
############################################

CPU_THRESHOLD=10        # seuil CPU en %
RAM_THRESHOLD=10       # seuil RAM en % (RAM_USAGE est en %)
MAIL_TO="alexis.noiret@laplateforme.io"
HOSTNAME=$(hostname)

ALERT_MSG=""

# Vérification CPU
if [ "$CPU_USAGE_INT" -gt "$CPU_THRESHOLD" ]; then
    ALERT_MSG+="Alerte CPU : utilisation = ${CPU_USAGE_INT}% (seuil = ${CPU_THRESHOLD}%)\n"
fi

# Vérification RAM
if [ "$RAM_USAGE" -gt "$RAM_THRESHOLD" ]; then
    ALERT_MSG+="Alerte RAM : utilisation = ${RAM_USAGE}% (seuil = ${RAM_THRESHOLD}%)\n"
fi

# Envoi du mail si nécessaire
if [ -n "$ALERT_MSG" ]; then
    echo -e "Machine : $HOSTNAME\n\n$ALERT_MSG" \
    | mail -s "⚠️ Alerte système sur $HOSTNAME" "$MAIL_TO"
fi

# --- Process info ---

mapfile -t CPU_TOP < <(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 4)

format_proc() {
    local pid name cpu mem
    read pid name cpu mem <<< "$1"
    echo "PID: $pid, Name: $name, CPU: $cpu%, RAM: $mem%"
}

TOP_PROCESS_1=$(format_proc "${CPU_TOP[1]}")
TOP_PROCESS_2=$(format_proc "${CPU_TOP[2]}")
TOP_PROCESS_3=$(format_proc "${CPU_TOP[3]}")

# --- File scan ---

declare -A COUNTS
declare -A SIZES
EXTENSIONS=(".txt" ".py" ".pdf" ".jpg" ".png" ".docx" ".xlsx" ".mp3" ".mp4" ".zip")

TOTAL_FILES=0
TOTAL_SIZE=0

mapfile -t LARGEST < <(find "$SCAN_DIR" -type f -printf "%s %p\n" 2>/dev/null | sort -nr | head -n 5)

while IFS= read -r -d '' file; do
    ((TOTAL_FILES++))
    size=$(stat -c %s "$file")
    ((TOTAL_SIZE+=size))

    for ext in "${EXTENSIONS[@]}"; do
        [[ "$file" == *"$ext" ]] && ((COUNTS[$ext]++)) && ((SIZES[$ext]+=size))
    done
done < <(find "$SCAN_DIR" -type f -print0 2>/dev/null)

FILE_STATS_HTML=""
for ext in "${EXTENSIONS[@]}"; do
    count=${COUNTS[$ext]:-0}
    size_mb=$(printf "%.2f" "$(echo "${SIZES[$ext]:-0} / 1024 / 1024" | bc -l)")
    percent=$(printf "%.2f" "$(echo "${SIZES[$ext]:-0} * 100 / ($TOTAL_SIZE+1)" | bc -l)")
    FILE_STATS_HTML+="<li>$ext: $count fichiers, $size_mb MB ($percent%)</li>"
done

LARGEST_HTML=""
for entry in "${LARGEST[@]}"; do
    size=$(echo "$entry" | awk '{print $1}')
    path=$(echo "$entry" | cut -d' ' -f2-)
    size_mb=$(printf "%.2f" "$(echo "$size / 1024 / 1024" | bc -l)")
    LARGEST_HTML+="<li>$path - $size_mb MB</li>"
done

# --- HTML generation ---

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
HTML=$(cat "$TEMPLATE")

declare -A VARS=(
    ["{{ timestamp }}"]="$TIMESTAMP"
    ["{{ hostname }}"]="$HOSTNAME"
    ["{{ os_name }}"]="$OS_NAME"
    ["{{ boot_time }}"]="$BOOT_TIME"
    ["{{ uptime }}"]="$UPTIME"
    ["{{ user_count }}"]="$USER_COUNT"
    ["{{ ip_address }}"]="$IP_ADDRESS"
    ["{{ cpu_cores }}"]="$CPU_CORES"
    ["{{ cpu_frequency }}"]="$CPU_FREQ"
    ["{{ cpu_usage }}"]="$CPU_USAGE_HTML"
    ["{{ total_ram }}"]="$TOTAL_RAM"
    ["{{ used_ram }}"]="$USED_RAM"
    ["{{ ram_usage }}"]="$RAM_USAGE_HTML"
    ["{{ load_avg }}"]="$LOAD1 / $LOAD5 / $LOAD15"
    ["{{ cpu_per_core }}"]="$CPU_PER_CORE_HTML"
    ["{{ top_process_1 }}"]="$TOP_PROCESS_1"
    ["{{ top_process_2 }}"]="$TOP_PROCESS_2"
    ["{{ top_process_3 }}"]="$TOP_PROCESS_3"
    ["{{ file_stats }}"]="$FILE_STATS_HTML"
    ["{{ largest_files }}"]="$LARGEST_HTML"
    ["{{ total_files }}"]="$TOTAL_FILES"
    ["{{ total_size }}"]="$(printf "%.2f GB" "$(echo "$TOTAL_SIZE / 1024 / 1024 / 1024" | bc -l)")"
)

for key in "${!VARS[@]}"; do
    HTML="${HTML//$key/${VARS[$key]}}"
done

echo "$HTML" > "$OUTPUT"
echo "Dashboard generated: $OUTPUT"
