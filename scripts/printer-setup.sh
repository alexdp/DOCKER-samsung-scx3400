#!/bin/bash
# Helper script for Samsung SCX-3400W printer setup

set -e

CONTAINER_NAME="samsung-scx3400-cups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Samsung SCX-3400W CUPS Setup Helper${NC}"
echo "===================================="
echo ""

# Check if container is running
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${RED}Error: Container $CONTAINER_NAME is not running${NC}"
    echo "Start it with: docker-compose up -d"
    exit 1
fi

# Function to show menu
show_menu() {
    echo ""
    echo "What would you like to do?"
    echo "1) View container logs"
    echo "2) View CUPS error log"
    echo "3) Restart CUPS service"
    echo "4) List configured printers"
    echo "5) Check USB devices"
    echo "6) Access container shell"
    echo "7) Backup CUPS configuration"
    echo "8) Test printer connection"
    echo "9) Exit"
    echo ""
    read -p "Enter your choice [1-9]: " choice
    
    case $choice in
        1)
            echo -e "${YELLOW}Container logs:${NC}"
            docker logs --tail 50 $CONTAINER_NAME
            ;;
        2)
            echo -e "${YELLOW}CUPS error log:${NC}"
            docker exec $CONTAINER_NAME tail -n 50 /var/log/cups/error_log
            ;;
        3)
            echo -e "${YELLOW}Restarting CUPS service...${NC}"
            docker restart $CONTAINER_NAME
            echo -e "${GREEN}CUPS service restarted${NC}"
            ;;
        4)
            echo -e "${YELLOW}Configured printers:${NC}"
            docker exec $CONTAINER_NAME lpstat -p -d
            ;;
        5)
            echo -e "${YELLOW}USB devices on host:${NC}"
            lsusb | grep -i samsung || echo "No Samsung USB devices found"
            echo ""
            echo -e "${YELLOW}USB devices in container:${NC}"
            docker exec $CONTAINER_NAME lsusb | grep -i samsung || echo "No Samsung USB devices found"
            ;;
        6)
            echo -e "${YELLOW}Accessing container shell...${NC}"
            docker exec -it $CONTAINER_NAME /bin/bash
            ;;
        7)
            BACKUP_DIR="./cups-backup-$(date +%Y%m%d-%H%M%S)"
            echo -e "${YELLOW}Backing up CUPS configuration to $BACKUP_DIR${NC}"
            mkdir -p $BACKUP_DIR
            docker cp $CONTAINER_NAME:/etc/cups $BACKUP_DIR/
            echo -e "${GREEN}Backup completed: $BACKUP_DIR${NC}"
            ;;
        8)
            echo -e "${YELLOW}Testing printer connection...${NC}"
            docker exec $CONTAINER_NAME lpstat -r
            echo ""
            docker exec $CONTAINER_NAME lpstat -v
            ;;
        9)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Main loop
while true; do
    show_menu
done
