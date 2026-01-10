#!/usr/bin/env bash
set -euo pipefail

# =====================
# CONFIG
# =====================
BASE_DIR="$HOME/recon"
TARGETS="$BASE_DIR/targets.txt"
BASE="$BASE_DIR/sub.txt"
TG_ID="mytg"

mkdir -p "$BASE_DIR"

# =====================
# SCAN SUBDOMAINS
# =====================
SCAN="$BASE_DIR/scan.txt"
subfinder -t 9999 -silent -dL "$TARGETS" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -d '\r' \
    | sed 's/\.$//; s/\$//; s/[[:space:]]*$//' \
    | sort -u > "$SCAN"

# =====================
# FIRST RUN BASELINE
# =====================
if [ ! -f "$BASE" ]; then
    cp "$SCAN" "$BASE"
    echo "[INIT] Baseline created ($(wc -l < "$BASE") subdomains)"
    rm -f "$SCAN"
    exit 0
fi

# =====================
# COMPARE VS BASELINE
# =====================
NEW="$BASE_DIR/new.txt"
comm -13 <(sort -u "$BASE") <(sort -u "$SCAN") > "$NEW"

# =====================
# RESULT / PRINT
# =====================
if [ -s "$NEW" ]; then
    COUNT=$(wc -l < "$NEW")
    echo "🎯 NEW SUBDOMAINS FOUND: $COUNT"
    cat "$NEW"

    # =====================
    # UPDATE BASELINE
    # =====================
    cat "$NEW" >> "$BASE"
    sort -u "$BASE" -o "$BASE"

    # =====================
    # OPTIONAL HTTP ENRICHMENT
    # =====================
    HTTP="$BASE_DIR/new_http.txt"
    httpx -silent -sc -l "$NEW" > "$HTTP" || true

    # =====================
    # TELEGRAM NOTIF
    # =====================
    notify -silent -id "$TG_ID" -i "$HTTP"

    # =====================
    # CLEANUP TEMP FILES
    # =====================
    rm -f "$NEW" "$HTTP"
else
    echo "✅ No new subdomains found."
    rm -f "$NEW"
fi

# =====================
# CLEANUP SCAN
# =====================
rm -f "$SCAN"
