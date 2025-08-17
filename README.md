# Package Installer & Maintenance Scripts for Arch Linux

## ⚠️ Warning
This script performs system maintenance tasks and requires **sudo/root access**.  
**Please review the script carefully** before running to understand its actions.

## Permissions

Make the scripts executable with:
```bash
chmod +x install-pkgs.sh pkgs-maintenance.sh
```

## Description

### install-pkgs.sh

Installs packages listed in `programs.sh` from official Arch repos and AUR (using yay).  
### pkgs-maintenance.sh

Performs maintenance by updating mirrorlist with reflector, cleaning caches, removing orphaned packages, and checking failed systemd services.

## Usage

1. Prepare a `programs.sh` file with packages to install as an array named `programs`.
2. Run the installer:  
```bash
./install-pkgs.sh
```

3. Run the maintenance script:  
```bash
./pkgs-maintenance.sh
```

## Learn More

For details on the commands and package management on Arch Linux, visit the [Arch Wiki](https://wiki.archlinux.org/).
