#!/usr/bin/env bash
set -euo pipefail

# =====================
# CONFIG
# =====================
BASE_DIR="$HOME/recon"
TARGETS="$BASE_DIR/targets.txt"

BASE="$BASE_DIR/sub.txt"
SCAN="$BASE_DIR/scan.txt"
NEW="$BASE_DIR/new.txt"
HTTP="$BASE_DIR/new.http"

TG_ID="mytg"
POPUP="$BASE_DIR/notify_wrapper.sh"

mkdir -p "$BASE_DIR"

# =====================
# ENUMERATION (LIST MODE)
# =====================
subfinder -t 9999 -silent -dL "$TARGETS" \
| tr -d '\r' \
| sed 's/\$//g; s/[[:space:]]*$//' \
| sort -u > "$SCAN"

# =====================
# FIRST RUN → CREATE BASELINE
# =====================
if [ ! -f "$BASE" ]; then
  cp "$SCAN" "$BASE"
  echo "[INIT] Baseline created"
  exit 0
fi

# =====================
# FIND NEW SUBDOMAINS
# =====================
comm -13 <(sort -u "$BASE") <(sort -u "$SCAN") > "$NEW"

# =====================
# IF NEW FOUND
# =====================
if [ -s "$NEW" ]; then
  httpx -silent -t 999 -sc -l "$NEW" > "$HTTP" || true

  notify -silent -id "$TG_ID" \
    -i "$HTTP" \

  "$POPUP" "🎯 Recon" "🆕 Subdomain baru:\n$(cat "$NEW")"

  # ⬇️ INI KUNCI NYA
  cat "$NEW" >> "$BASE"
  sort -u "$BASE" -o "$BASE"

else
  "$POPUP" "🎯 Recon" "✅ Tidak ada subdomain baru"
fi
