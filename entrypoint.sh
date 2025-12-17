#!/bin/bash
set -e

echo "[CUPS] Initializing..."

mkdir -p /run/cups
chown -R root:lp /run/cups

# Start CUPS
service cups start

# Wait CUPS daemon
echo "[CUPS] Waiting for daemon..."
for i in {1..15}; do
  if lpstat -r >/dev/null 2>&1; then
    echo "[CUPS] Daemon ready"
    break
  fi
  sleep 1
done

lpstat -r || { echo "[CUPS] FAILED"; exit 1; }

# Configure CUPS
cupsctl WebInterface=yes
cupsctl ServerAlias=*
cupsctl --remote-any --remote-admin --share-printers

# Création imprimante (idempotente)
if [[ -n "$PRINTER_NAME" && -n "$PRINTER_URL" ]]; then
  if ! lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
    lpadmin -p "$PRINTER_NAME" -E \
      -v "$PRINTER_URL" \
      -P /usr/share/ppd/suld/Samsung_SCX-3400_Series.ppd.gz
    cupsenable "$PRINTER_NAME"
    cupsaccept "$PRINTER_NAME"
  else
    echo "[CUPS] Printer already exists"
  fi
fi

echo "[CUPS] Ready"

# Keep container running
exec tail -f /dev/null
