# Voron Firmware Upgrade Guide

## 🚀 Automated Update Script (Recommended)

For routine updates, a script is available to pull the latest Klipper and Katapult code, build the firmware for both boards, and flash them automatically via Katapult.

```bash
# Make the script executable (first time only)
chmod +x scripts/update_firmware.sh

# Run the update
./scripts/update_firmware.sh
```

> **Note:** The script will ask for your confirmation before stopping Klipper and proceeding with the flash.

---

## Overview

This guide covers flashing Klipper firmware to the **Manta M8P V2** (main board) and the **EBB SB2209 CAN V1.0 (RP2040)** (toolhead board).

> **⚠️ Katapult Note:** Katapult is a bootloader and only needs to be flashed **once** per board. Once it is installed, you do not need to re-flash it on subsequent Klipper upgrades — simply use the Katapult flash method each time you update Klipper.

---

## Part 1: Manta M8P V2

### Flashing Klipper via DFU Mode

#### Step 1 — Build Klipper Firmware

Navigate to the Klipper directory and configure the build:

```bash
cd ~/klipper/
make clean
make menuconfig
```

Use the following settings in `menuconfig`:

```text
[*] Enable extra low-level configuration options
    Micro-controller Architecture (STMicroelectronics STM32)  --->
    Processor model (STM32H723)  --->
    Bootloader offset (128KiB bootloader)  --->
    Clock Reference (25 MHz crystal)  --->
    Communication interface (USB to CAN bus bridge (USB on PA11/PA12))  --->
    CAN bus interface (CAN bus (on PD0/PD1))  --->
    USB ids  --->
(1000000) CAN bus speed
()  GPIO pins to set at micro-controller startup
```

Press `q` to exit, then `Y` to save changes.

Compile the firmware:

```bash
make
```

#### Step 2 — Flash Klipper

Choose **one** of the two options below.

##### Option A — Flash via Katapult (recommended for updates)

> **ℹ️ Use this option for all future Klipper upgrades** once Katapult is installed.

Query the CAN bus for the board UUID:

```bash
python3 ~/Katapult/scripts/flashtool.py -i can0 -q
```

Flash Klipper using the UUID returned above:

```bash
python3 ~/Katapult/scripts/flash_can.py -i can0 -f ~/klipper/out/klipper.bin -u 9ec3edca21f7
```

##### Option B — Flash via DFU Mode

Enter DFU Mode

1. Turn on the printer.
2. Press and hold the **BOOT0** button.
3. Press and release the **RESET** button.
4. Release the **BOOT0** button.

Verify Connection

Run the following command to confirm the system detects the MCU in DFU mode:

```bash
lsusb
```

Expected output:

```text
Bus 002 Device 008: ID 0483:df11 STMicroelectronics STM Device in DFU Mode
```

> **⚠️ Replace `0483:df11` with the device ID shown by executing `lsusb` if it differs.**

```bash
sudo service klipper stop
sudo dfu-util -a 0 -d 0483:df11 -s 0x08020000:leave -D out/klipper.bin
sudo dfu-util -a 0 -D ~/klipper/out/klipper.bin --dfuse-address 0x08000000:force:mass-erase -d 0483:df11
make flash FLASH_DEVICE=0483:df11
sudo service klipper start
```

#### Step 3 — Confirm Success

After flashing, the log should contain `File downloaded successfully`.

> **ℹ️ Note:** Messages like `dfu-util: Error during download get_status` are harmless and can be safely ignored.

---

### Flashing Katapult to the Manta M8P (One-Time Setup)

> **⚠️ Only do this once.** Katapult is a bootloader — once it is installed, you do not need to re-flash it on future Klipper upgrades.

Use the following Katapult `menuconfig` settings:

```text
                                                       Katapult Configuration v0.0.1-113-gec59b9b
    Micro-controller Architecture (STMicroelectronics STM32)  --->
    Processor model (STM32H723)  --->
    Build Katapult deployment application (Do not build)  --->
    Clock Reference (25 MHz crystal)  --->
    Communication interface (USB (on PA11/PA12))  --->
    Application start offset (128KiB offset)  --->
    USB ids  --->
    Build Optimization Override (Size (-Os))  --->
()  GPIO pins to set on bootloader entry
[*] Support bootloader entry on rapid double click of reset button
[ ] Enable bootloader entry on button (or gpio) state
[*] Enable Status LED
(PA13)   Status LED GPIO Pin
```

Flash Katapult via DFU mode:

```bash
sudo dfu-util -a 0 -d 0483:df11 --dfuse-address 0x08000000:leave -D ~/Katapult/out/katapult.bin
```

---

## Part 2: EBB SB2209 CAN V1.0 (RP2040)

### Flashing Klipper

#### Step 1 — Build Klipper Firmware

Navigate to the Klipper directory and configure the build:

```bash
cd ~/klipper/
make clean
make menuconfig
```

Use the following settings in `menuconfig`:

```text
[*] Enable extra low-level configuration options
    Micro-controller Architecture (Raspberry Pi RP2040/RP235x)  --->
    Processor model (rp2040)  --->
    Bootloader offset (16KiB bootloader)  --->
    Communication Interface (CAN bus)  --->
(4) CAN RX gpio number
(5) CAN TX gpio number
(1000000) CAN bus speed
[*] Optimize stepper code for 'step on both edges'
```

Press `q` to exit, then `Y` to save changes.

Compile the firmware:

```bash
make
```

#### Step 2 — Flash Klipper

Choose **one** of the two options below.

##### Option A — Flash via Katapult (recommended for updates)

> **ℹ️ Use this option for all future Klipper upgrades** once Katapult is installed.

Query the CAN bus for the board UUID:

```bash
python3 ~/Katapult/scripts/flashtool.py -i can0 -q
```

Flash Klipper using the UUID returned above:

```bash
python3 ~/Katapult/scripts/flash_can.py -i can0 -f ~/klipper/out/klipper.bin -u 7fff144e6274
```

##### Option B — Flash via USB

Follow these steps carefully in order:

1. **Detach the CAN bus cable** from the EBB board.
2. **Install the USB_5V jumper** on the board.

   > *[Image placeholder — USB_5V jumper location]*

3. Connect the EBB SB2209 to the CB1 (Manta M8P) using a **USB Type-A to Type-C cable**.

4. **Enter DFU Mode:**
   - Press and hold the **BOOT** button.
   - Press and release the **RST** button.
   - Release the **BOOT** button.

5. **Verify the connection.** The board should appear as a RP2 Boot device:

   ```bash
   lsusb
   ```

   Expected output:

   ```text
   Bus 002 Device 006: ID 2e8a:0003 Raspberry Pi RP2 Boot
   ```

6. Flash the firmware:

   > **⚠️ Replace `2e8a:0003` with the device ID shown in the output above if it differs.**

   ```bash
   make flash FLASH_DEVICE=2e8a:0003
   sudo dfu-util -a 0 -d 2e8a:0003 -s 0x08020000:leave -D out/klipper.bin
   ```

7. **Unplug the USB cable.**
8. **Remove the USB_5V jumper** from pin 4.
9. **Reconnect the CAN bus cable.**

---

### Flashing Katapult to the EBB SB2209 (One-Time Setup)

> **⚠️ Only do this once.** Katapult is a bootloader — once it is installed, you do not need to re-flash it on future Klipper upgrades.

```bash
cd ~/Katapult
make clean
make menuconfig
```

Use the following settings in `menuconfig`:

```text
                                                       Katapult Configuration v0.0.1-113-gec59b9b
    Micro-controller Architecture (Raspberry Pi RP2040/RP235x)  --->
    Processor model (rp2040)  --->
    Flash chip (W25Q080 with CLKDIV 2)  --->
    Build Katapult deployment application (16KiB bootloader)  --->
    Communication Interface (CAN bus)  --->
(4) CAN RX gpio number
(5) CAN TX gpio number
(1000000) CAN bus speed
    Build Optimization Override (Size (-Os))  --->
()  GPIO pins to set on bootloader entry
[*] Support bootloader entry on rapid double click of reset button
[ ] Enable bootloader entry on button (or gpio) state
[*] Enable Status LED
(gpio26) Status LED GPIO Pin
```

Build and flash Katapult:

```bash
make
make flash FLASH_DEVICE=2e8a:0003
```

---
