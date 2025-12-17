#!/bin/bash
set -e

echo "Starting CUPS for Samsung SCX-3400W..."

# Start Avahi daemon for network printer discovery
if [ -x /usr/sbin/avahi-daemon ]; then
    /usr/sbin/avahi-daemon --daemonize
fi

# Create admin user if environment variables are set
if [ -n "$CUPS_USER" ] && [ -n "$CUPS_PASSWORD" ]; then
    echo "Creating CUPS admin user: $CUPS_USER"
    useradd -r -G lpadmin -M $CUPS_USER 2>/dev/null || true
    echo "$CUPS_USER:$CUPS_PASSWORD" | chpasswd
fi

# Set default admin user if not provided
if [ -z "$CUPS_USER" ]; then
    echo "Creating default CUPS admin user: admin"
    useradd -r -G lpadmin -M admin 2>/dev/null || true
    echo "admin:admin" | chpasswd
    echo "Default credentials - User: admin, Password: admin"
    echo "Please change the password after first login!"
fi

# Start CUPS in foreground
echo "CUPS is starting..."
echo "Web interface will be available at http://localhost:631"
echo "Admin interface: http://localhost:631/admin"

exec "$@"
