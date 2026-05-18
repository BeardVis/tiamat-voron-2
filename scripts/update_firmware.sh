#!/bin/bash

# --- Tiamat firmware update script ---
# Targets: 
# 1. BTT Manta M8P V2 (STM32H723)
# 2. BTT EBB SB2209 (RP2040)
# ----------------------------------------

set -euo pipefail

# Configuration
KLIPPER_DIR="../../klipper"
KATAPULT_DIR="../../Katapult"
MANTA_UUID="9ec3edca21f7"
EBB_UUID="7fff144e6274"
INTERFACE="can0"
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/update_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Redirect output to both terminal and log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo -e "${YELLOW}Starting firmware update process...${NC}"
echo "Log file: $LOG_FILE"

# Confirmation prompt
read -p "This script will stop Klipper and flash firmware to Manta and EBB. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Update cancelled by user.${NC}"
    exit 1
fi

# 1. Pull latest Klipper
echo -e "${GREEN}Updating Klipper source...${NC}"
cd "$KLIPPER_DIR"
git pull
cd - > /dev/null

# 2. Pull latest Katapult
echo -e "${GREEN}Updating Katapult source...${NC}"
cd "$KATAPULT_DIR"
git pull
cd - > /dev/null

# Stop Klipper service
echo -e "${YELLOW}Stopping Klipper service...${NC}"
sudo systemctl stop klipper

# 3. Build & Flash Manta M8P V2 (STM32H723)
echo -e "${GREEN}Building Klipper for Manta M8P V2...${NC}"
cd "$KLIPPER_DIR"
make clean

# Create a temporary config for Manta
cat > .config <<EOF
CONFIG_LOW_LEVEL_OPTIONS=y
CONFIG_MACH_STM32=y
CONFIG_BOARD_DIRECTORY="stm32"
CONFIG_MACH_STM32H723=y
CONFIG_FLASH_START_128K=y
CONFIG_STM32_CLOCK_REF_25M=y
CONFIG_CANBUS_BRIDGE=y
CONFIG_USB_PA11_PA12=y
CONFIG_CAN_ON_PD0_PD1=y
CONFIG_CANBUS_SPEED=1000000
EOF

make olddefconfig
make

echo -e "${GREEN}Flashing Manta M8P V2 via Katapult ($MANTA_UUID)...${NC}"
python3 "$KATAPULT_DIR/scripts/flash_can.py" -i "$INTERFACE" -f "$KLIPPER_DIR/out/klipper.bin" -u "$MANTA_UUID"

# 4. Build & Flash EBB SB2209 (RP2040)
echo -e "${GREEN}Building Klipper for EBB SB2209...${NC}"
make clean

# Create a temporary config for EBB
cat > .config <<EOF
CONFIG_LOW_LEVEL_OPTIONS=y
CONFIG_MACH_RP2040=y
CONFIG_BOARD_DIRECTORY="rp2040"
CONFIG_FLASH_START_16K=y
CONFIG_CANBUS=y
CONFIG_RP2040_CAN_TX_GPIO=5
CONFIG_RP2040_CAN_RX_GPIO=4
CONFIG_CANBUS_SPEED=1000000
CONFIG_STEPPER_BOTH_EDGES=y
EOF

make olddefconfig
make

echo -e "${GREEN}Flashing EBB SB2209 via Katapult ($EBB_UUID)...${NC}"
python3 "$KATAPULT_DIR/scripts/flash_can.py" -i "$INTERFACE" -f "$KLIPPER_DIR/out/klipper.bin" -u "$EBB_UUID"

# Restart Klipper service
echo -e "${YELLOW}Starting Klipper service...${NC}"
sudo systemctl start klipper

echo -e "${GREEN}Firmware update complete!${NC}"
