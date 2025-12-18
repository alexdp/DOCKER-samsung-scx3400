# Quick Start Guide - Samsung SCX-3400W Docker CUPS

This is a 5-minute setup guide to get your Samsung SCX-3400W working with Docker.

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Samsung SCX-3400W printer connected (USB or Network)
- 5 minutes of your time

## Step-by-Step Setup

### Step 1: Clone Repository (1 minute)

```bash
git clone https://github.com/alexdp/DOCKER-samsung-scx3400.git
cd DOCKER-samsung-scx3400
```

### Step 2: Start Container (2 minutes)

```bash
docker-compose up -d
```

Wait for the container to build and start. You'll see:
```
Creating samsung-scx3400-cups ... done
```

### Step 3: Open CUPS Web Interface (1 minute)

Open your web browser and go to:
```
http://localhost:631/admin
```

**Default Credentials:**
- Username: `admin`
- Password: `admin`

⚠️ Change these after first login!

### Step 4: Add Your Printer (2 minutes)

1. Click **"Add Printer"**
2. Select your Samsung SCX-3400W from the list
   - If USB: Should appear as "Samsung SCX-3400 USB"
   - If Network: Choose "Internet Printing Protocol (IPP)"
3. Click **"Continue"**
4. Select driver: **"Samsung SCX-3400 Series (en)"** or **"Samsung SCX-3400 (splix)"**
5. Click **"Add Printer"**
6. Configure default settings
7. Click **"Set Default Options"**

### Step 5: Test Print (1 minute)

1. Click **"Maintenance"** dropdown
2. Select **"Print Test Page"**
3. Your printer should now print a test page!

## What's Next?

### Print from Your Computer

**Windows:**
1. Settings → Devices → Printers
2. Add printer → The printer I want isn't listed
3. Select shared printer: `http://localhost:631/printers/Samsung_SCX-3400`

**Mac:**
1. System Preferences → Printers & Scanners
2. Click "+" to add
3. Enter IP: `localhost:631`

**Linux:**
1. System Settings → Printers
2. Add → Network Printer
3. Enter: `ipp://localhost:631/printers/Samsung_SCX-3400`

**Chromebook:**
1. Settings → Advanced → Printing
2. Add Printer
3. Enter: `localhost:631`

### Common Commands

**View logs:**
```bash
docker logs samsung-scx3400-cups
```

**Restart container:**
```bash
docker-compose restart
```

**Stop container:**
```bash
docker-compose down
```

**Access container shell:**
```bash
docker exec -it samsung-scx3400-cups /bin/bash
```

## Troubleshooting

### Printer Not Found?

**USB Connection:**
```bash
# On your host computer, run:
lsusb | grep Samsung

# If you see the printer, restart the container:
docker-compose restart
```

**Network Connection:**
- Make sure printer and computer are on same network
- Check printer's IP address
- Ensure port 631 is not blocked by firewall

### Can't Access Web Interface?

```bash
# Check if container is running:
docker ps | grep samsung

# Check logs for errors:
docker logs samsung-scx3400-cups

# Try accessing via IP instead of localhost:
http://192.168.1.X:631/admin
```

### Permission Denied?

```bash
# Add your user to docker group:
sudo usermod -aG docker $USER

# Log out and back in for changes to take effect
```

## Need More Help?

- Read the full [README.md](README.md) for detailed documentation
- Use the helper script: `./scripts/printer-setup.sh`
- Check [CONTRIBUTING.md](CONTRIBUTING.md) for how to report issues
- Visit CUPS documentation: https://www.cups.org/doc/

## Success! 🎉

Your Samsung SCX-3400W is now ready to use from any device on your network!

Don't forget to:
- ⚠️ Change the default admin password
- 🔒 Configure firewall rules if exposing to wider network
- 📝 Bookmark the CUPS interface: http://localhost:631

Happy printing! 🖨️
