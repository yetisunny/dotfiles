
#!/bin/bash

set -e  # Exit on any error

echo "==> Installing essential tools..."
sudo pacman -S --noconfirm --needed git base-devel

# Install yay if not found
if ! command -v yay &> /dev/null; then
  echo "==> Installing yay (AUR helper)..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

echo "==> Installing official packages from pkglist-pacman.txt..."
sudo pacman -S --needed - < ~/pkglist-pacman.txt

echo "==> Installing AUR packages from pkglist-aur.txt..."
yay -S --needed - < ~/pkglist-aur.txt

# ────────────────────────────────────────
# 🖋 Fonts
# ────────────────────────────────────────
echo "==> Installing fonts..."

# Nerd Fonts (choose your preferred ones)
yay -S --needed nerd-fonts-jetbrains-mono nerd-fonts-fira-code ttf-ubuntu-font-family


# ────────────────────────────────────────
# ✅ Done
# ────────────────────────────────────────
echo "🎉 All packages, fonts, and themes installed!"
