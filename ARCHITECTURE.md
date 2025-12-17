# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Devices                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Windows  │  │   Mac    │  │  Linux   │  │Chromebook│   │
│  │  Client  │  │  Client  │  │  Client  │  │  Client  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                      │
                      │ IPP/HTTP (Port 631)
                      │
┌─────────────────────▼─────────────────────────────────────┐
│                    Docker Host                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │     samsung-scx3400-cups Container                   │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐   │  │
│  │  │           CUPS Web Interface                 │   │  │
│  │  │         (http://localhost:631)               │   │  │
│  │  │    - Printer Management                      │   │  │
│  │  │    - Job Queue                                │   │  │
│  │  │    - Configuration                            │   │  │
│  │  └────────────────────┬─────────────────────────┘   │  │
│  │                       │                              │  │
│  │  ┌────────────────────▼──────────────────────────┐  │  │
│  │  │         CUPS Daemon (cupsd)                   │  │  │
│  │  │    - Print Job Processing                     │  │  │
│  │  │    - Queue Management                         │  │  │
│  │  │    - Filter Pipeline                          │  │  │
│  │  └────────────────────┬──────────────────────────┘  │  │
│  │                       │                              │  │
│  │  ┌────────────────────▼──────────────────────────┐  │  │
│  │  │        Printer Drivers                        │  │  │
│  │  │    - Splix Driver (Primary)                   │  │  │
│  │  │    - SULD Driver (Optional)                   │  │  │
│  │  │    - Samsung SPL Language Support             │  │  │
│  │  └────────────────────┬──────────────────────────┘  │  │
│  │                       │                              │  │
│  │  ┌────────────────────▼──────────────────────────┐  │  │
│  │  │       Avahi Daemon                            │  │  │
│  │  │    - Network Printer Discovery                │  │  │
│  │  │    - mDNS/DNS-SD Broadcasting                 │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  Volumes:                                            │  │
│  │  • /etc/cups        - Configuration                  │  │
│  │  • /var/spool/cups  - Print Queue                    │  │
│  │  • /var/log/cups    - Logs                           │  │
│  └───────────────────────┬───────────────────────────────┘  │
│                          │                                  │
│                          │ USB/Network                      │
└──────────────────────────┼──────────────────────────────────┘
                           │
                  ┌────────▼────────┐
                  │  Samsung SCX-   │
                  │  3400W Printer  │
                  │   & Scanner     │
                  └─────────────────┘
```

## Component Details

### 1. Docker Container

**Base Image:** Ubuntu 22.04 LTS
- Stable, well-supported Linux distribution
- Long-term support through 2027
- Wide compatibility with printer drivers

### 2. CUPS (Common UNIX Printing System)

**Version:** Latest from Ubuntu repositories

**Key Features:**
- **Web Interface:** Port 631 for remote management
- **IPP Support:** Industry-standard printing protocol
- **Network Access:** Configured to accept connections from any interface
- **Authentication:** Basic auth with customizable credentials

**Configuration Changes:**
```bash
# Listen on all interfaces
Listen 0.0.0.0:631

# Allow network access
Allow from all

# No encryption by default (can be enabled)
DefaultEncryption Never
```

### 3. Printer Drivers

#### Primary: Splix Driver (`printer-driver-splix`)
- **Type:** Open-source SPL (Samsung Printer Language) driver
- **Maintained:** Active community support
- **Compatibility:** Samsung SCX-3400 series
- **Features:** Full printing support

#### Secondary: SULD (Samsung Unified Linux Driver)
- **Type:** Official Samsung driver (when available)
- **Repository:** http://www.bchemnet.com/suldr/
- **Features:** Scanner support included
- **Status:** Optional, fallback to Splix

### 4. Avahi Daemon

**Purpose:** Network printer discovery
- **Protocol:** mDNS/DNS-SD (Bonjour/Zeroconf)
- **Benefit:** Automatic printer detection on network
- **Compatibility:** Works with Windows, Mac, Linux, Chrome OS

### 5. Volume Mounts

**Persistent Storage:**

1. **cups-config** → `/etc/cups`
   - Printer configurations
   - CUPS settings
   - Access control

2. **cups-spool** → `/var/spool/cups`
   - Print job queue
   - Temporary print files
   - Job history

3. **cups-log** → `/var/log/cups`
   - Access logs
   - Error logs
   - Page logs

## Data Flow

### Print Job Workflow

```
Client → IPP Request → CUPS Web Interface
                          ↓
                    CUPS Daemon
                          ↓
                    Job Queue
                          ↓
                   Print Filters
                          ↓
                   Printer Driver
                          ↓
              Samsung SPL Data Stream
                          ↓
           USB/Network Connection
                          ↓
              Samsung SCX-3400W
```

### Configuration Workflow

```
User → Web Browser (port 631) → CUPS Admin Interface
                                        ↓
                                  cupsd.conf
                                        ↓
                                  printers.conf
                                        ↓
                                 CUPS Daemon
                                        ↓
                               Printer Configuration
```

## Network Ports

| Port | Protocol | Purpose              | Access        |
|------|----------|----------------------|---------------|
| 631  | HTTP     | CUPS Web Interface   | All Devices   |
| 631  | IPP      | Print Job Submission | All Devices   |
| 5353 | mDNS     | Printer Discovery    | Local Network |

## Security Model

### Access Control
1. **Authentication Required** for administrative tasks
2. **Default Credentials:** admin/admin (should be changed)
3. **Network Access:** Allowed from all interfaces (can be restricted)

### Security Recommendations
- Change default password immediately
- Use firewall rules to restrict port 631 access
- Consider adding SSL/TLS encryption
- Run on isolated network segment for production

## File Structure

```
DOCKER-samsung-scx3400/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Deployment configuration
├── entrypoint.sh          # Container startup script
├── README.md              # Full documentation
├── QUICKSTART.md          # Quick setup guide
├── ARCHITECTURE.md        # This file
├── CONTRIBUTING.md        # Contribution guidelines
├── LICENSE                # MIT License
├── cups.conf.sample       # CUPS configuration template
├── .gitignore            # Git ignore rules
├── .dockerignore         # Docker build ignore rules
└── scripts/
    └── printer-setup.sh  # Helper utility script
```

## Dependencies

### Runtime Dependencies
- CUPS core packages
- CUPS filters
- Splix driver
- Avahi daemon
- Python 3 (for CUPS utilities)
- libusb (for USB access)

### Build Dependencies
- Docker Engine 20.10+
- Docker Compose (optional)

## Scalability

### Single Printer
- Current configuration
- One Samsung SCX-3400W

### Multiple Printers
- Can manage multiple Samsung printers
- Add additional printer configurations via CUPS web interface
- Each printer gets unique queue

### Network Deployment
- Can serve entire office network
- Multiple clients can print simultaneously
- Job queuing handles concurrent requests

## Troubleshooting Architecture

```
Problem Report
      ↓
Check Container Status (docker ps)
      ↓
Review Logs (docker logs)
      ↓
Check CUPS Error Log (/var/log/cups/error_log)
      ↓
Verify USB Connection (lsusb)
      ↓
Test CUPS Service (lpstat -r)
      ↓
Verify Printer Configuration (CUPS web interface)
```

## Future Enhancements

Potential improvements to the architecture:

1. **SSL/TLS Support**: HTTPS for web interface
2. **LDAP Integration**: Enterprise authentication
3. **Email Notifications**: Job completion alerts
4. **Metrics/Monitoring**: Prometheus exporter
5. **Multi-Architecture**: ARM support for Raspberry Pi
6. **Cloud Integration**: Remote printing capabilities

## References

- [CUPS Documentation](https://www.cups.org/doc/)
- [Splix Driver](http://splix.sourceforge.net/)
- [Samsung SULD](http://www.bchemnet.com/suldr/)
- [Docker Documentation](https://docs.docker.com/)
