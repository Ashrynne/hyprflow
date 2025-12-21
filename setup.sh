#!/bin/bash

# =======================================================
# HYPRFLOW SETUP SCRIPT (ARCH LINUX)
# =======================================================

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run with sudo to install dependencies."
  exit 1
fi

echo "--- Phase 1: System Packages ---"
pacman -S --noconfirm jq libnotify nodejs npm

echo "--- Phase 2: Playwright Core ---"
cd "$SCRIPT_DIR"
# for browser control
npm install playwright-core

echo "--- Phase 3: Permissions ---"
chmod +x "$SCRIPT_DIR/hyprflow.sh"
chmod +x "$SCRIPT_DIR/close-tab.js"

echo ""
echo "Setup Complete. Browsers must use --remote-debugging-port=9222"
