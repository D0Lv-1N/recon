#!/usr/bin/env bash
# -------------------------------------------------
# notify_wrapper.sh – wrapper untuk notifikasi desktop
# -------------------------------------------------
# 1. Set environment yang diperlukan
#    DISPLAY biasanya :0 (jika Anda hanya memiliki satu X server)
#    DBUS_SESSION_BUS_ADDRESS = socket DBus milik user yang menjalankan wrapper
# -------------------------------------------------
export DISPLAY=:0                                   # <-- display X server
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus   # <-- sesi DBus

# 2. Dapatkan dua argumen pertama:
#    $1 = judul (title), $2 = pesan (message)
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 \"Judul\" \"Pesan (bisa berisi newline)\"" >&2
    exit 1
fi

TITLE="$1"
MESSAGE="$2"

# 3. Kirim notifikasi lewat notify-send
#    -silent   : tidak menunggu balasan (cron‑friendly)
#    -u normal : tingkat keprioritas (low, normal, critical)
#    -i        : (opsional) path ke ikon; kita tidak pakai ikon di sini
notify-send  -u normal "$TITLE" "$MESSAGE"

