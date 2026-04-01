#!/usr/bin/env bash
set -e

mkdir -p ~/.config/powershell
ln -sf ~/dotfiles/.config/powershell/Microsoft.PowerShell_profile.ps1 \
       ~/.config/powershell/Microsoft.PowerShell_profile.ps1

echo "Dotfiles installed."