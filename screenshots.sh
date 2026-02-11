#!/bin/bash
#
# SkyUp Screenshot Tool (wrapper)
#
# Installs dependencies if needed and runs the Python screenshot tool.
# For direct usage: python3 screenshots.py [options]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not installed."
    exit 1
fi

# Install Playwright if missing
if ! python3 -c "import playwright" 2>/dev/null; then
    echo "Installing Playwright..."
    python3 -m ensurepip 2>/dev/null || true
    python3 -m pip install playwright
    python3 -m playwright install chromium

    # Install system dependencies (RHEL/Fedora)
    if command -v dnf &> /dev/null; then
        echo "Installing system dependencies..."
        sudo dnf install -y nspr nss nss-util atk at-spi2-atk cups-libs \
            libdrm libXcomposite libXdamage libXrandr mesa-libgbm pango \
            alsa-lib libxkbcommon 2>/dev/null || true
    fi
fi

exec python3 "$SCRIPT_DIR/screenshots.py" "$@"
