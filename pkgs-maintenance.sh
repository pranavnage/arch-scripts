#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Update Pacman mirrors with reflector
echo -e "${BLUE}:: Updating Pacman mirrorlist with reflector...${NC}"

if ! command -v reflector &>/dev/null; then
  read -p "Reflector is not installed. Do you want to install it? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing reflector now..."
    sudo pacman -S --noconfirm reflector
  else
    echo "Reflector installation skipped."
  fi
fi

if command -v reflector &>/dev/null; then
  sudo reflector --latest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  echo -e "${GREEN}:: Mirrorlist updated.${NC}"
else
  echo -e "${GREEN}:: Mirrorlist not updated as reflector is not installed.${NC}"
fi

# Clean the package and build cache
echo -e "\n${BLUE}:: Cleaning package cache...${NC}"
if command -v yay &>/dev/null; then
  yay -Scc --noconfirm
else
  sudo paccache -r
fi
echo -e "${GREEN}:: Cache cleaning complete.${NC}"

# Check for and remove orphaned packages
echo -e "\n${BLUE}:: Checking for orphaned packages...${NC}"
if [[ -n $(pacman -Qdtq) ]]; then
  echo "The following orphaned packages will be removed:"
  pacman -Qdt
  sudo pacman -Rns $(pacman -Qdtq) --noconfirm
else
  echo "No orphaned packages to remove."
fi

# Check for failed systemd services
echo -e "\n${BLUE}:: Checking for failed systemd services...${NC}"
if [[ -n $(systemctl --failed --no-pager) ]]; then
  systemctl --failed --no-pager
else
  echo "No failed systemd services found."
fi

echo -e "\n${GREEN}:: Maintenance complete!${NC}"
