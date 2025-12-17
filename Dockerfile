# Docker image for Samsung SCX-3400W printer/scanner with CUPS
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install CUPS, necessary tools, and dependencies
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    cups-bsd \
    cups-filters \
    samba-client \
    printer-driver-splix \
    wget \
    curl \
    libcups2 \
    libcupsimage2 \
    avahi-daemon \
    avahi-utils \
    python3 \
    python3-cups \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install Samsung Unified Linux Driver (optional)
# The SPL (Samsung Printer Language) driver is needed for SCX-3400 series
# The splix driver (printer-driver-splix) is already installed as a fallback
# and should work with most Samsung printers including SCX-3400
RUN mkdir -p /tmp/samsung && \
    cd /tmp/samsung && \
    (wget -q http://www.bchemnet.com/suldr/pool/debian/extra/su/suldr-keyring_2_all.deb && \
    dpkg -i suldr-keyring_2_all.deb && \
    echo "deb http://www.bchemnet.com/suldr/ debian extra" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y suld-driver-3.00.90) || \
    echo "SULD driver installation skipped, using splix driver as fallback" && \
    rm -rf /tmp/samsung

# Configure CUPS
# Allow access from network
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow from all/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow from all\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow from all/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# Create necessary directories
RUN mkdir -p /var/run/cups /var/spool/cups /var/log/cups

# Expose CUPS web interface and IPP port
EXPOSE 631

# Add startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /etc/cups

# Start CUPS
ENTRYPOINT ["/entrypoint.sh"]
CMD ["cupsd", "-f"]
