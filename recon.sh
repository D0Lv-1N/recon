#!/usr/bin/env bash
set -euo pipefail

# =========================
# CONFIG
# =========================
BASE_DIR="$HOME/recon"
STATE_DIR="$BASE_DIR/state"
TG_ID="mytg"
POPUP="$BASE_DIR/notify_wrapper.sh"

# =========================
# LOOP DOMAIN
# =========================
while IFS= read -r DOMAIN || [ -n "$DOMAIN" ]; do
  [ -z "$DOMAIN" ] && continue

  DDIR="$STATE_DIR/$DOMAIN"
  SUB="$DDIR/sub.txt"     # baseline
  SCAN="$DDIR/scan.txt"  # live scan
  NEW="$DDIR/new.txt"
  HTTP="$DDIR/new.http"

  mkdir -p "$DDIR"

  # =========================
  # ENUM SUBDOMAIN → scan.txt
  # =========================
  TMP="$DDIR/tmp.txt"
  : > "$TMP"

  subfinder -t 999 -silent -d "$DOMAIN" >> "$TMP"
  assetfinder --subs-only "$DOMAIN" >> "$TMP"
  findomain -t "$DOMAIN" 2>/dev/null | grep -E "\.${DOMAIN}$" >> "$TMP"

  sort -u "$TMP" > "$SCAN"
  rm -f "$TMP"

  # =========================
  # FIRST RUN (NO BASELINE)
  # =========================
  if [ ! -f "$SUB" ]; then
    cp "$SCAN" "$SUB"
    echo "[INIT] Baseline created for $DOMAIN"
    continue
  fi

  # =========================
  # COMPARE scan vs sub
  # =========================
  comm -13 <(sort -u "$SUB") <(sort -u "$SCAN") > "$NEW"

  # =========================
  # IF NEW SUBDOMAIN FOUND
  # =========================
  if [ -s "$NEW" ]; then
    httpx -silent -t 999 -sc -l "$NEW" > "$HTTP" || true

    # --- TELEGRAM ---
    if [ -s "$HTTP" ]; then
      notify -silent -id "$TG_ID" \
        -i "$HTTP" \
        -mf "🎯 $DOMAIN\n🆕 {{data}}\n⏰ $(date '+%F %T')"
    else
      notify -silent -id "$TG_ID" \
        -mf "🎯 $DOMAIN\n🆕 Subdomain baru:\n$(cat $NEW)\n⏰ $(date '+%F %T')"
    fi

    # --- DESKTOP POPUP ---
    MSG=$( [ -s "$HTTP" ] && cat "$HTTP" || cat "$NEW" )
    "$POPUP" "🎯 $DOMAIN" "🆕 Subdomain baru:\n$MSG"

    # update baseline
    cat "$NEW" >> "$SUB"
    sort -u "$SUB" -o "$SUB"

  else
    # =========================
    # NO NEW SUBDOMAIN
    # =========================
    "$POPUP" "🎯 $DOMAIN" "✅ Tidak ada subdomain baru"
  fi

done < "$BASE_DIR/targets.txt"

