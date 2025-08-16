#!/bin/bash

if [[ -f "programs.sh" ]]; then
  source "programs.sh"
else
  echo "Error: programs.sh not found. Please create a file named programs.sh"
  echo "with a 'programs' array containing the list of packages to install."
  exit 1
fi

declare -a installed_packages
declare -a skipped_packages
declare -a failed_packages

is_package_installed() {
  local package=$1
  if pacman -Q "$package" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

install_package() {
  local package=$1

  if is_package_installed "$package"; then
    echo "$package is already installed. Skipping..."
    skipped_packages+=("$package")
    return
  fi

  if pacman -Si "$package" &>/dev/null; then
    echo "Installing $package from official repositories..."
    if sudo pacman -S --noconfirm --needed "$package" &>/dev/null; then
      installed_packages+=("$package")
    else
      failed_packages+=("$package")
    fi
  elif yay -Si "$package" &>/dev/null; then
    echo "Installing $package from AUR..."
    if yay -S --noconfirm "$package" &>/dev/null; then
      installed_packages+=("$package")
    else
      failed_packages+=("$package")
    fi
  else
    echo "Error: $package not found in official repositories or AUR."
    failed_packages+=("$package")
  fi
}

if ! command -v yay &>/dev/null; then
  echo "Yay is not installed. Installing it now..."

  sudo pacman -Sy --needed --noconfirm base-devel

  (
    cd /tmp || exit
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin || exit
    makepkg -si --noconfirm
  )

  rm -rf /tmp/yay-bin

  if ! command -v yay &>/dev/null; then
    echo "Failed to install yay. Exiting."
    exit 1
  fi
fi

echo "Updating package databases..."
sudo pacman -Sy
yay -Syy

for program in "${programs[@]}"; do
  install_package "$program"
done

echo -e "\n=== Installation Summary ==="
echo "Installed packages (${#installed_packages[@]}):"
if [ ${#installed_packages[@]} -eq 0 ]; then
  echo "  None"
else
  for pkg in "${installed_packages[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\nSkipped packages (${#skipped_packages[@]}):"
if [ ${#skipped_packages[@]} -eq 0 ]; then
  echo "  None"
else
  for pkg in "${skipped_packages[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\nFailed packages (${#failed_packages[@]}):"
if [ ${#failed_packages[@]} -eq 0 ]; then
  echo "  None"
else
  for pkg in "${failed_packages[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\nInstallation process completed."
