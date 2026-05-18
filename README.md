# Voron 2.4 300×300 — *Tiamat*

*Tiamat* is a custom [Voron 2.4](https://github.com/VoronDesign/Voron-2) CoreXY 3D printer build (300×300×280 mm print volume), focused on high-speed, reliable printing via CAN bus toolhead communication and a clean Klipper/Mainsail software stack.

![Status](https://img.shields.io/badge/Status-Stable-green)
![License](https://img.shields.io/badge/License-GPLv3-blue)

---

## Table of Contents

- [Hardware Specifications](#hardware-specifications)
- [Toolhead: Stealthburner (Clockwork 2)](#toolhead-stealthburner-clockwork-2)
- [Software & Architecture](#software--architecture)
- [Klipper Extensions](#klipper-extensions)
- [Configuration](#configuration)
- [CAD Models](#cad-models)
- [Firmware Flashing](#firmware-flashing)
- [Pending Upgrades](#pending-upgrades)
- [Future Investigations](#future-investigations)
- [Engineering Notes](#engineering-notes)
- [Official Resources](#official-resources)
- [License](#license)

---

## Hardware Specifications

### Motion System

| Component | Part |
| --- | --- |
| Mainboard | BTT Manta M8P V2 + CB1 compute module |
| X/Y Stepper Drivers | BIGTREETECH TMC2240 V1.0 |
| Z Stepper Drivers | BIGTREETECH TMC2209 V1.3 |
| X/Y Motors | Mellow LDO 42STH48-2504MAC(F) — 48mm NEMA 17 |
| Z Motors | G-PENNY 42HS4825A4 — NEMA 17 |
| X/Y Homing | Sensorless Homing (TMC2240 StallGuard) |

### Power & Electronics

| Component | Part |
| --- | --- |
| Power Supply | MEANWELL LRS-350-24 (350W, 24V) |
| AC Inlet | DaierTek 250VAC IEC inlet with Fuse & EMI Filter (DR-6A2FI3L) |
| Solid State Relay | GTHURCS GTX-1 D4825 (25A AC-DC) |

### Heated Bed

| Component | Part |
| --- | --- |
| Heating Pad | FYSETC 300×300 Perforated Silicone Pad (220V, 750W) |
| Thermal Sensor | Generic NTC 3950 (built-in) |

### Mods

| Mod | Purpose |
| --- | --- |
| [BFI — Beefy Front Idlers](https://github.com/clee/VoronBFI) | Improved X/Y belt tensioning and rigidity |
| [BZI — Beefy Z Idlers](https://github.com/clee/VoronBFI) | Improved Z belt path durability |
| [GE5C Z joints](https://mods.vorondesign.com/details/eB5T2RNQcYI4o6cilhpXEg) | Spherical bearings for improved Z-axis alignment |
| [FilamATrix Mod](https://github.com/thunderkeys/FilamATrix) | Kinetic filament cutter with toolhead-level D2F sensor |
| Custom Umbilical | Single 4-wire cable (Power + CAN) with [custom gantry mount](./CAD/umbilical_mount.f3d) |

### Sensors & Monitoring

| Component | Part |
| --- | --- |
| Filament Sensor | [BTT Smart Filament Sensor V2.0](https://github.com/bigtreetech/smart-filament-detection-module/tree/master/V2.0) with [custom mount](./CAD/sfs_mount.f3d) |
| Chamber Sensor | [AHT30 Temperature & Humidity Sensor](https://www.aliexpress.com/item/1005008053575938.html) with [custom bracket](./CAD/aht30_mount.f3d) (mounted to umbilical) |

---

## Toolhead: Stealthburner (Clockwork 2)

| Component | Part |
| --- | --- |
| Toolboard | [BTT EBB SB2209 CAN V1.0 (RP2040)](https://github.com/bigtreetech/EBB/tree/master/EBB%20SB2209%20CAN%20(RP2040)) |
| Extruder Motor | Mellow High Temp LDO-36STH20-1004AHG — NEMA 14 |
| Hotend | [E3D Revo Voron](https://e3d-online.com/blogs/news/revo-voron-available-now) |
| Part Cooling Fan | GDSTIME GDB5015 — DC 24V 0.1A |
| Hotend Fan | GDSTIME GDA4010 — DC 24V 0.04A |
| Z-Homing & Bed Leveling | [Cartographer V4](https://cartographer3d.com/) (Standard CAN) |
| Toolhead Mount | [Cartographer3D CNC Toolhead Mount & Carriage](https://cartographer3d.com/products/voron-2-4-cnc-carriage-mount-for-v6-mount-style-probes) |
| Display | [BTT KNOMI V2.0](https://global.bttwiki.com/KNOMI2.html) (integrated into Stealthburner) |

---

## Software & Architecture

### System Stack

| Layer | Component |
| --- | --- |
| OS | [Armbian](https://armbian.com/boards/bigtreetech-cb1) |
| Web Interface | [Mainsail](https://docs.mainsail.xyz/mainsailos/) + [Moonraker](https://moonraker.readthedocs.io/) |
| Firmware | [Klipper](https://www.klipper3d.org/) |
| Bootloader | [Katapult](https://github.com/Arksine/katapult) |

### CAN Bus Topology

The printer uses CAN bus at **1,000,000 baud** for clean, low-wiring toolhead communication.

```text
Host (CB1)
  └── USB
      └── BTT Manta M8P V2  (USB-to-CAN bridge via PA11/PA12)
              └── CAN bus
                  ├── BTT EBB SB2209 (toolhead board)
                  └── Cartographer V4
```

The Manta M8P V2 acts as the USB-to-CAN bridge — no dedicated CAN adapter is required.

---

## Klipper Extensions

| Extension | Purpose | Config |
| --- | --- | --- |
| [tmc_autotune](https://github.com/andrewmcgr/klipper_tmc_autotune) | Automatic TMC driver tuning and motor optimization | [`config/tmc_autotune.cfg`](./config/tmc_autotune.cfg) |

---

## Configuration

The printer configuration is split across modular files in the [`config/`](./config/) directory.

- **Entry point:** [`config/printer.cfg`](./config/printer.cfg)
- Each subsystem (motion, extruder, bed, fans, etc.) is maintained as a separate `[include]` file for clarity.

---

## CAD Models

Custom 3D-printable parts designed for this build are available in the [`CAD/`](./CAD/) directory.

See [**CAD/README.md**](./CAD/README.md) for a detailed list and descriptions of all custom models.

---

## Firmware Flashing

See [**Update.md**](./Update.md) for full step-by-step instructions covering:

- STM32 flashing (Manta M8P V2 via Katapult/DFU)
- RP2040 flashing (EBB SB2209 via Katapult over CAN)

> ⚠️ WARNING
>
> The automated update script [`scripts/update_firmware.sh`](./scripts/update_firmware.sh) is currently **untested**. It is strongly recommended to follow the manual steps in `Update.md` instead of using this script.

---

## Pending Upgrades

The following hardware additions are planned but not yet installed or configured:

- [ ] **Replace Hotend Fan** — Add tachometer-equipped fan for [Hotend Fan RPM Monitoring](https://ellis3dp.com/Print-Tuning-Guide/articles/hotend_fan_monitoring.html) (Ellis' Print Tuning Guide)
  - 12V options:
    - Sunon `MF40101VX-1000U-G99`
    - Delta `AFB0412VHA-DU48`
  - 24V options:
    - NMB `04010SS-24N-AT-00`
    - Orion `OD4010-24HB01A`
- [ ] **[Blobifier](https://github.com/Carrot-collective/Blobifier)** — Nozzle purging system (required for multi-material)
- [ ] **Enclosure**
  - [ ] Activated carbon filter — investigate [Nevermore Micro](https://github.com/nevermore3d/Nevermore_Micro)
  - [ ] Panel latches — investigate [snap latches mod](https://mods.vorondesign.com/details/9Rdnf5vD2oaJLmR7BpAuQ)

---

## Future Investigations

Long-term additions under consideration:

- **[Filamentalist Rewinder](https://github.com/Carrot-collective/ERCF_v2/tree/master/Recommended_Options/Filamentalist_Rewinder)** — Passive filament-driven buffer/rewinder for MMU setups
- **[ERCF V3 (Enraged Rabbit Carrot Feeder)](https://github.com/Carrot-collective/ERCF_v3)** — Multi-material printing unit
- [Enclosure Camera](https://3do.dk/en/3do-camera/2683-3do-usb-enclosure-camera-kit-v2-sony-4k-for-3d-printers.html)

---

## Engineering Notes

### Extruder Grounding (EMI/ESD Fix)

One of the critical hardware iterations in this build was addressing EMI and Static Electricity (ESD) issues related to the extruder motor within the Stealthburner toolhead.

**The Problem:** During long prints, the NEMA 14 motor can accumulate static charges. Since the Stealthburner is primarily plastic, this charge has no path to ground, leading to intermittent CAN bus communication errors and random MCU shutdowns.

**The Solution:** A dedicated grounding wire was added, connecting the metal casing of the extruder motor directly to the printer's common ground (frame/PSU V-).

**Result:** Complete elimination of "Timer too close" and communication timeout errors.

> **⚠️ Software Caveat:** It has been observed that applying `tmc_autotune` to the extruder motor can sometimes trigger similar communication errors. If issues persist after grounding, consider disabling `tmc_autotune` for the extruder.

---

## Official Resources

| Resource | Link |
| --- | --- |
| Voron 2.4 Design | [vorondesign.com](https://vorondesign.com/) · [GitHub](https://github.com/VoronDesign/Voron-2) |
| Klipper Firmware | [klipper3d.org](https://www.klipper3d.org/) |
| Mainsail OS | [docs.mainsail.xyz](https://docs.mainsail.xyz/mainsailos/) |
| BTT Manta M8P V2 | [GitHub](https://github.com/bigtreetech/Manta-M8P) |
| BTT EBB SB2209 CAN | [GitHub](https://github.com/bigtreetech/EBB/tree/master/EBB%20SB2209%20CAN%20(RP2040)) |

---

## License

The configuration files, macros, and personal documentation in this repository are licensed under the **GNU General Public License v3.0**.

This project is a derivative of the [Voron 2.4](https://github.com/VoronDesign/Voron-2) design by [Voron Design](https://vorondesign.com/), which is also GPLv3 licensed.

See [LICENSE](./LICENSE) for full terms.