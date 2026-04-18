#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── rcm ──────────────────────────────────────────────────────────────────────
if ! command -v rcup &>/dev/null; then
  echo "rcm is not installed. Install it first (e.g. nix-env -iA nixpkgs.rcm, brew install rcm, or apt install rcm)."
  exit 1
fi

echo "Linking dotfiles with rcm..."
env RCRC="$DOTFILES_DIR/rcrc" rcup -v

# ── PowerShell profile ────────────────────────────────────────────────────────
mkdir -p ~/.config/powershell
ln -sf "$DOTFILES_DIR/.config/powershell/Microsoft.PowerShell_profile.ps1" \
       ~/.config/powershell/Microsoft.PowerShell_profile.ps1

# ── NixOS configuration ───────────────────────────────────────────────────────
if [ -f "$DOTFILES_DIR/configuration.nix" ]; then
  echo "Installing NixOS configuration to /etc/nixos/configuration.nix..."
  sudo cp "$DOTFILES_DIR/configuration.nix" /etc/nixos/configuration.nix
  echo "NixOS configuration installed. Run 'sudo nixos-rebuild switch' to apply."
fi

echo "Dotfiles installed."
