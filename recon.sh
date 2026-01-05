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
TMP="$BASE_DIR/tmp.txt"
: > "$TMP"

subfinder -t 9999 -silent -dL "$TARGETS" >> "$TMP"
assetfinder --subs-only < "$TARGETS" >> "$TMP"
findomain -f "$TARGETS" 2>/dev/null >> "$TMP"

sort -u "$TMP" > "$SCAN"
rm -f "$TMP"

# =====================
# FIRST RUN → CREATE BASELINE
# =====================
if [ ! -f "$BASE" ]; then
  cp "$SCAN" "$BASE"
  echo "[INIT] Baseline created"
  exit 0
fi

# =====================
# COMPARE
# =====================
comm -13 <(sort -u "$BASE") <(sort -u "$SCAN") > "$NEW"

# =====================
# IF NEW FOUND
# =====================
if [ -s "$NEW" ]; then
  httpx -silent -t 9999 -sc -l "$NEW" > "$HTTP" || true

  # --- TELEGRAM ---
  if [ -s "$HTTP" ]; then
    notify -silent -id "$TG_ID" \
      -data "$HTTP" \
      -mf "🎯 NEW ASSET\n🆕 {{data}}\n⏰ $(date '+%F %T')"
  else
    notify -silent -id "$TG_ID" \
      -mf "🎯 NEW ASSET\n🆕 $(cat $NEW)\n⏰ $(date '+%F %T')"
  fi

  # --- DESKTOP ---
  MSG=$( [ -s "$HTTP" ] && cat "$HTTP" || cat "$NEW" )
  "$POPUP" "🎯 Recon" "🆕 Subdomain baru:\n$MSG"

  # update baseline
  cat "$NEW" >> "$BASE"
  sort -u "$BASE" -o "$BASE"

else
  # =====================
  # NO NEW
  # =====================
  "$POPUP" "🎯 Recon" "✅ Tidak ada subdomain baru"
fi
