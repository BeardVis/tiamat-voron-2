# Project Instructions

## Agent Role

Writing and documentation assistant for a Klipper 3D printer repository.

**Do:** Read files, write/fix config files, write/fix shell scripts, write documentation, explain config values, suggest commands.  
**Do not:** Execute any command, script, or shell code.

---

## Repository Layout

| Path | Description |
|---|---|
| `docs/` | Component descriptions, wiring, bill of materials |
| `config/` | Klipper firmware configuration |
| `config/moonraker.conf` | Moonraker API server configuration |
| `slicer_profiles/` | OrcaSlicer printer profile(s) — JSON format |
| `scripts/` | Firmware update and maintenance shell scripts |

If the actual layout differs, ask the user before editing anything.

---

## Core Rules

1. **Never change calibration values** (`rotation_distance`, `microsteps`, `full_steps_per_rotation`, `pid_Kp`, `pid_Ki`, `pid_Kd`, `z_offset`, `pressure_advance`) unless the user explicitly provides a new measured value.
2. **Never delete a config section** without knowing what hardware it controls — ask first.
3. **One concern per file change.** Do not mix a Klipper fix with a script refactor.
4. **Explain every non-obvious line** with an inline `# reason:` comment.
5. **Never invent values.** Do not guess part numbers, pin names, or defaults — ask.

---

## Klipper Config (`config/`)

- Do not reformat `.cfg` files — Klipper config is indentation-sensitive.
- When fixing a syntax error, show a before/after diff of the affected lines only.
- When writing a `[gcode_macro]`, check for name collisions with existing macros and Klipper built-ins.
- Use `variable_*` fields in macros instead of hardcoded numbers.
- Do not write or reformat the `[save_config]` block — it is machine-generated and must remain exactly as Klipper writes it.

**Klipper section map (reference):**

```
[mcu]              – microcontroller serial connection
[printer]          – kinematics type, max velocity/accel
[stepper_x/y/z]   – motor tuning per axis
[extruder]         – hotend, thermistor, PID, pressure advance
[heater_bed]       – bed heater and PID
[probe] / [bltouch] / [beacon] – bed leveling sensor
[bed_mesh]         – automatic mesh leveling parameters
[fan] / [heater_fan] / [controller_fan] – cooling
[display]          – optional screen
[gcode_macro]      – custom G-code macros
[save_config]      – auto-written calibration block (bottom of file)
```

---

## Moonraker Config (`moonraker.conf`)

- Do not broaden `trusted_clients` or `cors_domains` beyond what the user specifies.
- Do not duplicate section names — Moonraker silently ignores or errors on duplicates.
- Every `[update_manager]` entry must include: `type`, `channel`, `origin` (git URL), `path`. Do not write an entry without confirming the repo URL and branch with the user.

---

## OrcaSlicer Profiles (`slicer_profiles/`)

- Do not write a filament profile from scratch — copy the nearest existing profile as a base.
- Do not put retraction settings in the printer profile — they belong in per-filament profiles.
- Keep these fields consistent with `printer.cfg`:

| OrcaSlicer field | Must match |
|---|---|
| `nozzle_diameter` | Physical nozzle installed |
| `bed_size_x/y` | `[printer]` `max_position` |
| `start_gcode/end_gcode` | Macros that exist in `printer.cfg` |

- Prefer calling macros (`PRINT_START`, `PRINT_END`) in gcode fields over raw G-code.
- After any edit, verify the JSON is well-formed.

---

## Scripts (`scripts/`)

Do not run scripts. When writing or reviewing them, enforce:

- Starts with `set -euo pipefail`. Add it if missing.
- Serial port paths are named variables at the top, not hardcoded strings.
- Every destructive step (erase, flash, overwrite) has a confirmation prompt before executing.
- Output is logged to a timestamped file under `logs/`. Suggest adding this if absent.
- A comment at the top identifies which MCU/board the script targets.

---

## Component Documentation (`docs/`)

Every component doc must include:

- Exact part number or model (not generic name).
- Electrical specs: voltage, current draw, connector type.
- Wiring table for anything connected to the MCU:

```markdown
| Signal | MCU Pin |
|--------|---------|
| GND    | GND     |
| 5V     | 5V      |
| Signal | PA1     |
```

- Mark wear-prone parts with `⚠️ Keep spare`.

---

## Checklist Before Finishing a Task

- [ ] No calibration values changed without a user-supplied measured value
- [ ] All edited `.cfg` sections are syntactically valid (indentation, no duplicate keys)
- [ ] All edited JSON files are well-formed
- [ ] Scripts have `set -euo pipefail`, named serial port variables, and confirmation prompts before destructive steps
- [ ] New components documented with exact part number, specs, and wiring table
- [ ] Non-obvious lines have `# reason:` comments
- [ ] No commands were executed