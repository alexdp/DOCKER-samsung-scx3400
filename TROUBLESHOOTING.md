# Troubleshooting Guide

Common issues and their solutions for Samsung SCX-3400W Docker CUPS setup.

## Table of Contents
1. [Container Issues](#container-issues)
2. [Printer Detection Issues](#printer-detection-issues)
3. [Network Access Issues](#network-access-issues)
4. [Print Job Issues](#print-job-issues)
5. [Scanner Issues](#scanner-issues)
6. [Performance Issues](#performance-issues)
7. [Driver Issues](#driver-issues)

---

## Container Issues

### Container Won't Start

**Symptoms:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:631: bind: address already in use
```

**Solution:**
```bash
# Check if CUPS is running on host
sudo systemctl status cups

# Stop host CUPS service
sudo systemctl stop cups
sudo systemctl disable cups

# Or change port in docker-compose.yml
ports:
  - "6631:631"  # Use different port
```

### Container Crashes Immediately

**Check logs:**
```bash
docker logs samsung-scx3400-cups
```

**Common causes:**
- Insufficient permissions
- USB device not accessible
- Volume mount issues

**Solution:**
```bash
# Restart with verbose logging
docker-compose down
docker-compose up

# Check permissions
ls -la /dev/usb*
```

### Cannot Access Container

**Verify container is running:**
```bash
docker ps | grep samsung
```

**If not running:**
```bash
docker-compose up -d
```

**If running but unresponsive:**
```bash
docker restart samsung-scx3400-cups
```

---

## Printer Detection Issues

### Printer Not Found (USB)

**Check USB connection on host:**
```bash
lsusb | grep Samsung
```

**Expected output:**
```
Bus 001 Device 004: ID 04e8:XXXX Samsung Electronics Co., Ltd SCX-3400 Series
```

**If not visible:**
- Check USB cable
- Try different USB port
- Reconnect printer

**Check USB in container:**
```bash
docker exec samsung-scx3400-cups lsusb | grep Samsung
```

**If not visible in container:**
```bash
# Stop container
docker-compose down

# Check device permissions on host
ls -la /dev/usb/
ls -la /dev/bus/usb/

# Adjust docker-compose.yml if needed
devices:
  - /dev/bus/usb:/dev/bus/usb

# Restart
docker-compose up -d
```

### Printer Not Found (Network)

**Check network connectivity:**
```bash
# From host
ping [printer-ip]

# From container
docker exec samsung-scx3400-cups ping [printer-ip]
```

**Check printer's network settings:**
- Ensure printer is on same network
- Check printer IP address (print config page)
- Verify printer network is enabled

**Try manual printer addition:**
1. Go to http://localhost:631/admin
2. Click "Add Printer"
3. Select "Internet Printing Protocol (ipp)"
4. Enter: `ipp://[printer-ip]:631/ipp/print`

---

## Network Access Issues

### Cannot Access CUPS Web Interface

**Test local access:**
```bash
curl http://localhost:631
```

**If fails:**
```bash
# Check if port is listening
netstat -tuln | grep 631

# Check Docker port mapping
docker port samsung-scx3400-cups
```

**Test from another computer:**
```bash
# Replace with your Docker host IP
curl http://192.168.1.X:631
```

**Check firewall:**
```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 631/tcp

# CentOS/RHEL
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=631/tcp --permanent
sudo firewall-cmd --reload
```

### Can Access Web Interface But Cannot Add Printer

**Symptoms:**
- "Authentication Required" repeatedly
- "Forbidden" error

**Solutions:**

1. **Clear browser cache and cookies**

2. **Try different browser**

3. **Check credentials:**
   - Default: admin/admin
   - Check docker-compose.yml for CUPS_USER/CUPS_PASSWORD

4. **Reset admin password:**
```bash
docker exec -it samsung-scx3400-cups /bin/bash
# Inside container:
passwd admin
# Or recreate user:
userdel admin
useradd -r -G lpadmin -M admin
echo "admin:newpassword" | chpasswd
exit
```

---

## Print Job Issues

### Print Jobs Stuck in Queue

**Check status:**
```bash
docker exec samsung-scx3400-cups lpstat -p
docker exec samsung-scx3400-cups lpstat -o
```

**Cancel stuck jobs:**
```bash
# Cancel specific job
docker exec samsung-scx3400-cups cancel [job-id]

# Cancel all jobs
docker exec samsung-scx3400-cups cancel -a
```

**Restart printer queue:**
```bash
docker exec samsung-scx3400-cups cupsenable Samsung_SCX-3400
docker exec samsung-scx3400-cups cupsaccept Samsung_SCX-3400
```

**Check printer errors:**
```bash
docker exec samsung-scx3400-cups tail -f /var/log/cups/error_log
```

### Print Jobs Complete But Nothing Prints

**Verify printer is ready:**
- Check printer display for errors
- Ensure paper is loaded
- Check toner/ink levels
- Verify printer is online (not paused)

**Test printer connection:**
```bash
# Get printer URI
docker exec samsung-scx3400-cups lpstat -v

# Test with simple job
echo "Test" | docker exec -i samsung-scx3400-cups lp
```

**Check printer state:**
```bash
docker exec samsung-scx3400-cups lpstat -t
```

### Poor Print Quality

**Printer maintenance:**
- Clean print heads
- Check toner/ink levels
- Align print heads
- Update printer firmware

**Check print settings:**
1. Go to http://localhost:631/printers/Samsung_SCX-3400
2. Click "Set Default Options"
3. Adjust quality settings
4. Click "Set Default Options"

---

## Scanner Issues

### Scanner Not Detected

**Check SANE installation:**
```bash
docker exec samsung-scx3400-cups scanimage -L
```

**Expected output:**
```
device 'samsung:libusb:...' is a Samsung SCX-3400 multi-function peripheral
```

**If not found:**
```bash
# Install additional SANE drivers
docker exec samsung-scx3400-cups apt-get update
docker exec samsung-scx3400-cups apt-get install -y sane-utils libsane-extras
```

**Configure SANE for network access:**
Create file `/etc/sane.d/net.conf` in container:
```bash
docker exec samsung-scx3400-cups bash -c 'echo "localhost" > /etc/sane.d/net.conf'
```

---

## Performance Issues

### Slow Print Times

**Check container resources:**
```bash
docker stats samsung-scx3400-cups
```

**If CPU/Memory high:**
- Reduce print quality
- Print fewer pages at once
- Allocate more resources in docker-compose.yml:

```yaml
services:
  cups-samsung-scx3400:
    # Add resource limits
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
```

### Web Interface Slow

**Clear CUPS cache:**
```bash
docker exec samsung-scx3400-cups rm -rf /var/cache/cups/*
docker restart samsung-scx3400-cups
```

**Reduce log verbosity:**
Edit in container or via volume mount:
```bash
# In /etc/cups/cupsd.conf
LogLevel warn  # Instead of debug
```

---

## Driver Issues

### Wrong Driver Selected

**List available drivers:**
```bash
docker exec samsung-scx3400-cups lpinfo -m | grep -i samsung
```

**Change driver:**
1. Go to http://localhost:631/printers/Samsung_SCX-3400
2. Click "Modify Printer"
3. Select different driver
4. Click "Modify Printer"

**Recommended drivers for SCX-3400:**
- Samsung SCX-3400 Series (splix)
- Samsung SCX-3400 (SULD)

### Need to Install Custom Driver

**Copy PPD file to container:**
```bash
# On host, download PPD file
# Copy to container
docker cp samsung.ppd samsung-scx3400-cups:/usr/share/cups/model/

# Restart CUPS
docker restart samsung-scx3400-cups
```

---

## Advanced Troubleshooting

### Enable Debug Logging

**Edit CUPS configuration:**
```bash
docker exec -it samsung-scx3400-cups /bin/bash
# Inside container:
sed -i 's/LogLevel .*/LogLevel debug/' /etc/cups/cupsd.conf
systemctl restart cups  # or restart container
exit
```

**View detailed logs:**
```bash
docker exec samsung-scx3400-cups tail -f /var/log/cups/error_log
```

### Collect Diagnostic Information

**Run diagnostic script:**
```bash
#!/bin/bash
echo "=== Docker Version ==="
docker --version

echo "=== Container Status ==="
docker ps | grep samsung

echo "=== Container Logs ==="
docker logs --tail 50 samsung-scx3400-cups

echo "=== CUPS Status ==="
docker exec samsung-scx3400-cups lpstat -t

echo "=== USB Devices ==="
lsusb | grep Samsung

echo "=== Network Status ==="
netstat -tuln | grep 631

echo "=== CUPS Error Log ==="
docker exec samsung-scx3400-cups tail -20 /var/log/cups/error_log
```

Save as `diagnostics.sh`, make executable, and run:
```bash
chmod +x diagnostics.sh
./diagnostics.sh > diagnostic-report.txt
```

### Reset Everything

**Complete reset:**
```bash
# Stop and remove container
docker-compose down -v

# Remove volumes (WARNING: Deletes all config)
docker volume rm DOCKER-samsung-scx3400_cups-config
docker volume rm DOCKER-samsung-scx3400_cups-spool
docker volume rm DOCKER-samsung-scx3400_cups-log

# Remove image
docker rmi samsung-scx3400-cups-test

# Rebuild and start fresh
docker-compose build --no-cache
docker-compose up -d
```

---

## Getting Help

If none of these solutions work:

1. **Collect diagnostic information** (see above)
2. **Check container logs:**
   ```bash
   docker logs samsung-scx3400-cups > logs.txt
   ```
3. **Open an issue on GitHub** with:
   - Description of problem
   - Steps to reproduce
   - Diagnostic information
   - Log files
   - Your environment (OS, Docker version)

## Useful Commands Reference

```bash
# Container management
docker-compose up -d              # Start
docker-compose down               # Stop
docker-compose restart            # Restart
docker-compose logs -f            # Follow logs

# CUPS commands (inside container)
lpstat -t                        # Show all status
lpstat -p                        # Show printers
lpstat -o                        # Show jobs
lpinfo -m                        # List drivers
lpinfo -v                        # List devices
lp filename                      # Print file
cancel -a                        # Cancel all jobs

# Helper script
./scripts/printer-setup.sh       # Interactive menu
```

## Additional Resources

- [CUPS Documentation](https://www.cups.org/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Samsung Printer Support](https://www.samsung.com/support/)
- [SANE Documentation](http://www.sane-project.org/)
- [Splix Driver Docs](http://splix.sourceforge.net/)
