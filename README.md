# Samsung SCX-3400W Docker CUPS Solution

Docker container with pre-configured CUPS (Common UNIX Printing System) for the Samsung SCX-3400W printer/scanner device. This solution allows you to use your Samsung SCX-3400W on modern systems including Windows (via network printing) and Chromebooks, even though official drivers are no longer supported.

## Features

- 🖨️ **Full CUPS Support**: Complete printing system with web interface
- 📡 **Network Printing**: Access printer from any device on your network
- 🔍 **Scanner Support**: Includes Samsung Unified Linux Driver with scanner capabilities
- 🌐 **Web Management**: Easy printer configuration via web interface (port 631)
- 🐳 **Containerized**: Clean, isolated environment that won't affect your system
- 🔄 **Persistent Storage**: Configuration and print queues survive container restarts

## Requirements

- Docker (version 20.10 or higher recommended)
- Docker Compose (optional, for easier deployment)
- Samsung SCX-3400W printer connected via USB or network
- Network access for the container

## Quick Start

### Using Docker Compose (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/alexdp/DOCKER-samsung-scx3400.git
cd DOCKER-samsung-scx3400
```

2. Build and start the container:
```bash
docker-compose up -d
```

3. Access the CUPS web interface:
- Open your browser and go to `http://localhost:631`
- For admin tasks: `http://localhost:631/admin`
- Default credentials: `admin` / `admin` (please change after first login)

### Using Docker CLI

1. Build the image:
```bash
docker build -t samsung-scx3400-cups .
```

2. Run the container:
```bash
docker run -d \
  --name samsung-scx3400-cups \
  --network host \
  --privileged \
  -e CUPS_USER=admin \
  -e CUPS_PASSWORD=admin \
  -v cups-config:/etc/cups \
  -v cups-spool:/var/spool/cups \
  -v cups-log:/var/log/cups \
  --device /dev/usb:/dev/usb \
  -p 631:631 \
  samsung-scx3400-cups
```

## Configuration

### Adding Your Printer

1. Go to `http://localhost:631/admin`
2. Click "Add Printer"
3. Log in with your credentials (default: admin/admin)
4. Select your Samsung SCX-3400W from the list
5. Choose the Samsung SCX-3400 driver (should be pre-installed)
6. Configure printer settings as needed
7. Click "Add Printer"

### Environment Variables

- `CUPS_USER`: Admin username for CUPS web interface (default: `admin`)
- `CUPS_PASSWORD`: Admin password for CUPS web interface (default: `admin`)

### USB Connection

If your printer is connected via USB:

1. Find the USB device on your host:
```bash
lsusb | grep Samsung
```

2. Make sure the device path is correctly mounted in docker-compose.yml or your docker run command

### Network Connection

For network-connected printers:
1. Access the CUPS web interface
2. Add printer using the network discovery or IPP protocol
3. Use the printer's IP address

## Using from Windows

1. Go to Settings > Devices > Printers & scanners
2. Click "Add a printer or scanner"
3. Click "The printer that I want isn't listed"
4. Select "Select a shared printer by name"
5. Enter: `http://[your-server-ip]:631/printers/[printer-name]`
6. Follow the wizard to complete installation

## Using from Chromebook

1. Go to Settings > Advanced > Printing > Printers
2. Click "Add Printer"
3. Enter your server IP address and port 631
4. Select your printer from the list
5. Click "Add"

## Scanner Support

The Samsung Unified Linux Driver includes scanner support. To use the scanner:

1. Install SANE tools on your host system
2. Configure SANE to access the network scanner
3. The scanner should be accessible via the CUPS server

## Troubleshooting

### Printer not detected

- Verify USB connection: `lsusb` on host
- Check container logs: `docker logs samsung-scx3400-cups`
- Ensure the container has access to USB devices

### Cannot access web interface

- Check if the container is running: `docker ps`
- Verify port 631 is not blocked by firewall
- Try accessing via host IP instead of localhost

### Permission issues

- The container runs in privileged mode for USB access
- Ensure your user is in the docker group: `sudo usermod -aG docker $USER`

### Print jobs stuck

- Check CUPS error log: `docker exec samsung-scx3400-cups tail /var/log/cups/error_log`
- Restart the container: `docker-compose restart`

## Maintenance

### View logs
```bash
docker logs samsung-scx3400-cups
```

### Access container shell
```bash
docker exec -it samsung-scx3400-cups /bin/bash
```

### Update the container
```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

### Backup configuration
```bash
docker cp samsung-scx3400-cups:/etc/cups ./cups-backup
```

## Security Notes

⚠️ **Important Security Recommendations:**

1. **Change default password**: The default admin/admin credentials should be changed immediately
2. **Network access**: By default, CUPS is accessible from any network interface. Consider restricting access in production
3. **Firewall**: Use firewall rules to limit access to port 631
4. **HTTPS**: For production use, consider setting up HTTPS/SSL for the CUPS web interface

## Technical Details

### Base Image
- Ubuntu 22.04 LTS

### Installed Components
- CUPS (Common UNIX Printing System)
- Samsung Unified Linux Driver (SULD)
- Splix driver (SPL support)
- Avahi daemon (network discovery)
- SANE scanner support

### Supported Models
This container is specifically configured for:
- Samsung SCX-3400
- Samsung SCX-3400W
- Samsung SCX-3405 (may work with similar configuration)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is provided as-is for personal use. Samsung and SCX-3400W are trademarks of Samsung Electronics.

## Support

For issues and questions:
- Open an issue on GitHub
- Check CUPS documentation: https://www.cups.org/doc/
- Samsung Unified Linux Driver: http://www.bchemnet.com/suldr/

## Acknowledgments

- CUPS Project: https://www.cups.org/
- Samsung Unified Linux Driver Repository: http://www.bchemnet.com/suldr/
- Community contributors and testers