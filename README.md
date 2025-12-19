# NixOS Configuration — xps-nixos-colton

This repository contains my **NixOS system configuration** using **flakes** and **Home Manager**.
It is currently set up for a single laptop host (`xps-nixos-colton`) and is structured so it can
easily be extended to additional machines later.

## Overview

- **System**: NixOS (flakes, nixos-unstable)
- **User config**: Home Manager (as a NixOS module)
- **WM**: Hyprland
- **Theming**: Catppuccin
- **Status**: Laptop-only (Dell XPS), multi-host ready


### Notes on Structure

- `hosts/xps-nixos-colton/`
  - Contains **machine-specific** system configuration.
  - `hardware-configuration.nix` must **never** be reused on other machines.
- `home.nix` and related directories (`hypr/`, `waybar/`, `kitty/`, `hm-modules/`)
  - Managed via Home Manager.
  - Mostly portable across machines.
- `flake.nix`
  - Defines the NixOS system, Home Manager integration, and theming modules.

## Applying the Configuration

From the repository root:

```bash
sudo nixos-rebuild switch --flake .#xps-nixos-colton
