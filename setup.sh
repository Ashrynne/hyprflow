#!/bin/bash

# =======================================================
# HYPRFLOW SETUP SCRIPT (ARCH LINUX)
# =======================================================
# This script installs all necessary system packages (jq, libnotify, nodejs, npm)
# and installs the local project dependency (playwright) into this directory.
#
# NOTE: This script assumes you are running a Pacman-based distribution (like Arch Linux).
# =======================================================

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PACKAGE_LIST="jq libnotify nodejs npm"

# --- Helper Function: Check for Sudo ---
if [ "$EUID" -ne 0 ]; then
  echo "You must run this script with sudo privileges (i.e., 'sudo ./setup.sh')."
  exit 1
fi

# --- Phase 1: Install System Packages ---

echo "=========================================="
echo "PHASE 1: Installing Core System Dependencies..."
echo "Required Packages: $PACKAGE_LIST"
echo "=========================================="

# -Sy updates package lists, --noconfirm bypasses prompts for a smooth install.
pacman -Sy --noconfirm $PACKAGE_LIST

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERROR: Pacman failed to install one or more system packages."
    echo "Please ensure your system is up-to-date and try again."
    exit 1
fi

echo ""
echo "✅ System dependencies installed successfully."


# --- Phase 2: Install Local Playwright Dependency ---

echo "=========================================="
echo "PHASE 2: Installing Playwright (Node.js dependency)..."
echo "This will install Playwright and download necessary browser binaries."
echo "=========================================="

# Navigate to the script directory to ensure npm installs locally
pushd "$SCRIPT_DIR" > /dev/null

# Install Playwright locally. 
npm install playwright 

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERROR: npm failed to install Playwright."
    echo "Please ensure Node.js and npm were installed correctly in Phase 1."
    popd > /dev/null
    exit 1
fi

popd > /dev/null # Return to original directory
echo ""
echo "✅ Playwright and required browser binaries installed successfully into: $SCRIPT_DIR/node_modules"


# --- Phase 3: Finalize Setup ---

echo "=========================================="
echo "PHASE 3: Finalizing Permissions and Instructions"
echo "=========================================="

# Ensure the main scripts are executable
chmod +x "$SCRIPT_DIR/hyprflow.sh"
# The js script does not strictly need execute permission as it is run via 'node'

echo ""
echo "=========================================="
echo "🚀 HYPRFLOW SETUP COMPLETE!"
echo "=========================================="
echo "You can now run Hyprflow using: '$SCRIPT_DIR/hyprflow.sh'"
echo ""
echo "‼️ CRITICAL MANUAL STEP REQUIRED ‼️"
echo "To enable the browser tab-closing feature, you MUST edit your Hyprland configuration file:"
echo "------------------------------------------"
echo "1. Locate your browser's launch command in your hyprland.conf (or autostart script)."
echo "2. Add the remote debugging flag (use port 9222):"
echo ""
echo "   Example (Brave):"
echo '   exec-once = brave-browser --remote-debugging-port=9222'
echo ""
echo "3. Restart Hyprland or restart your browser to apply the change."
echo "------------------------------------------"
