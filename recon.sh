#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/recon"
STATE_DIR="$BASE_DIR/state"
TG_ID="mytg"

while read -r DOMAIN; do
    [ -z "$DOMAIN" ] && continue

    DDIR="$STATE_DIR/$DOMAIN"
    BASE="$DDIR/sub.txt"
    SCAN="$DDIR/scan.txt"
    NEW="$DDIR/new.txt"
    HTTP_RESULTS="$DDIR/new.http"

    mkdir -p "$DDIR"

    # enum subdomain
    TMP="$DDIR/tmp.txt"
    : > "$TMP"

    # Subfinder
    subfinder -t 999 -d "$DOMAIN" | tee -a "$TMP"

    # Assetfinder
    assetfinder --subs-only "$DOMAIN" | tee -a "$TMP"

    # Findomain (filter output to only include domain lines)
    findomain -t "$DOMAIN" 2>/dev/null | grep -E "^[a-zA-Z0-9.-]+\.$DOMAIN$" | tee -a "$TMP"

    sort -u "$TMP" > "$SCAN"
    rm -f "$TMP"

    # init baseline
    if [ ! -f "$BASE" ]; then
        cp "$SCAN" "$BASE"
        echo "✅ Baseline created for $DOMAIN"
        continue
    fi

    # diff new
    comm -13 <(sort -u "$BASE") <(sort -u "$SCAN") > "$NEW"

    if [ -s "$NEW" ]; then
        # Ada subdomain baru
        echo "🆕 New subdomains found for $DOMAIN"

        # Validasi HTTP dan dapatkan status code
        # Filter new.txt untuk hanya subdomain yang valid
        grep -E "^[a-zA-Z0-9.-]+\.$DOMAIN$" "$NEW" > "$DDIR/new_valid.txt"

        if [ -s "$DDIR/new_valid.txt" ]; then
            httpx -t 99 -sc -l "$DDIR/new_valid.txt" | tee "$HTTP_RESULTS"
        else
            echo "No valid subdomains found in new.txt"
            : > "$HTTP_RESULTS"
        fi

        # Kirim notif Telegram dengan status code
        if [ -s "$HTTP_RESULTS" ]; then
            notify -silent -provider telegram \
                -i "$HTTP_RESULTS" \
                -mf $'🎯 '"$DOMAIN"$'\n🆕 {{data}}\n⏰ '"$(date '+%F %T')"
        fi

        # Update baseline
        cat "$NEW" >> "$BASE"
        sort -u "$BASE" -o "$BASE"

        # Kirim notif PC
        if [ -s "$HTTP_RESULTS" ]; then
            MSG=$(paste -sd '\n' "$HTTP_RESULTS")
            notify-send "🎯 $DOMAIN" "🆕 Subdomain baru ditemukan:\n$MSG\n⏰ $(date '+%F %T')" -u normal
        else
            notify-send "🎯 $DOMAIN" "🆕 Subdomain baru ditemukan (HTTP check failed)\n⏰ $(date '+%F %T')" -u normal
        fi
    else
        # Tidak ada subdomain baru
        echo "✅ No new subdomains for $DOMAIN"

        # Hanya kirim notif PC
        notify-send "🎯 $DOMAIN" "✅ Tidak ada subdomain baru\n⏰ $(date '+%F %T')" -u low
    fi

done < "$BASE_DIR/targets.txt"
