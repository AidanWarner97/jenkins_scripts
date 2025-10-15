#!/bin/bash

# === Config ===
CODENAME="$1"
STATUS="$2"
FILENAME="${3:-}"
API_URL="https://dashboard.evolution-x.nl/_API/buildStatus.php?action=updateStatus"

# === cURL Request ===
curl -X POST "$API_URL" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-urlencode "c=$CODENAME" \
     --data-urlencode "f=$FILENAME" \
     --data-urlencode "s=$STATUS"
