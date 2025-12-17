#!/bin/bash

# === Config ===
CODENAME="$1"
BUILDTYPE="$2"
STATUS="$3"
PATH_INPUT="$4"

EvoVersion=$(
    grep -E '^EVO_VERSION_BASE' "$PATH_INPUT/vendor/lineage/config/version.mk" \
    | awk -F':= *' '{print $2}' | tr -d ' '
)

API_URL="https://mm-dashboard.evolution-x.org/_API/buildStatus.php?action=updateStatus"

# === cURL Request ===
curl -X POST "$API_URL" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-urlencode "c=$CODENAME" \
     --data-urlencode "bt=$BUILDTYPE" \
     --data-urlencode "s=$STATUS" \
     --data-urlencode "ev=$EvoVersion"
