# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a ZMK (Zephyr Mechanical Keyboard) configuration for the MoErgo Glove80 keyboard. It's a template repository that users fork to create custom keyboard layouts and build firmware.

## Build Commands

**Primary build method (Docker-based):**
- `./build.sh` - Builds firmware using Docker (Linux/macOS)
- `build.bat` - Builds firmware using Docker (Windows)
- Both scripts accept an optional branch parameter (defaults to 'main')

**Direct build (requires Nix):**
- `nix-build ./config --arg firmware 'import /src/default.nix {}' -o glove80.uf2`

The build process creates `glove80.uf2` firmware file that can be flashed to the keyboard.

## Architecture

### Core Files
- `config/glove80.keymap` - Main keymap configuration in ZMK's device tree format
- `config/glove80.conf` - Keyboard configuration options (currently empty)
- `config/default.nix` - Nix build configuration that combines left/right keyboard halves
- `Dockerfile` - Multi-stage container that builds ZMK firmware using Nix

### Build System
The project uses a Nix-based build system inside Docker:
1. Uses nixpkgs/nix:nixos-23.11 base image
2. Clones moergo-sc/zmk repository (ZMK fork for Glove80)
3. Uses Nix to build firmware for both keyboard halves (glove80_lh/glove80_rh)
4. Combines both halves into single .uf2 firmware file

### Keymap Structure
The keymap defines 4 layers:
- `DEFAULT (0)` - Standard QWERTY layout with F-keys
- `LOWER (1)` - Function keys, numpad, and navigation
- `MAGIC (2)` - RGB controls, Bluetooth, and system functions
- `FACTORY_TEST (3)` - Hardware testing layer

Key behaviors include:
- Tap dance for layer switching (`layer_td`)
- Hold-tap for magic layer access (`magic`)
- Bluetooth profile macros (`bt_0` through `bt_3`)

## Development Workflow

1. Modify `config/glove80.keymap` for layout changes
2. Run build script to generate firmware
3. Flash `glove80.uf2` to keyboard following MoErgo documentation
4. GitHub Actions automatically builds firmware on push to repository

## References
- ZMK documentation: https://zmk.dev/docs
- MoErgo Glove80 support: https://moergo.com/glove80-support
- Official ZMK fork: https://github.com/moergo-sc/zmk