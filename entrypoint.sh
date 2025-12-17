#!/bin/bash
set -e

echo "[CUPS] Initializing..."

mkdir -p /run/cups
chown -R root:lp /run/cups

# 🔥 Lancer cupsd DIRECTEMENT en foreground, mais en background shell
cupsd -f &
CUPSD_PID=$!

# Attendre que CUPS réponde
echo "[CUPS] Waiting for daemon..."
for i in {1..15}; do
  if lpstat -r >/dev/null 2>&1; then
    echo "[CUPS] Daemon ready"
    break
  fi
  sleep 1
done

lpstat -r || { echo "[CUPS] FAILED"; exit 1; }

# Configuration CUPS
cupsctl WebInterface=yes
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

# 🔒 Passer cupsd en PID 1 proprement
wait $CUPSD_PID
