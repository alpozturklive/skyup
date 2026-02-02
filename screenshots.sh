#!/bin/bash

# Create screenshots directory
mkdir -p screenshots

# URLs to screenshot
declare -A urls=(
    ["open-webui"]="http://127.0.0.1:8080"
    ["n8n"]="http://127.0.0.1:5678"
)

# Check if shot-scraper is installed
if ! command -v shot-scraper &> /dev/null; then
    echo "Installing shot-scraper..."
    pip install shot-scraper
fi

# Take screenshots
for name in "${!urls[@]}"; do
    echo "📸 Taking screenshot of $name (${urls[$name]})..."
    shot-scraper "${urls[$name]}" \
        -o "screenshots/${name}.png" \
        --width 1920 \
        --height 1080 \
        --wait 2000
    echo "✅ Saved: screenshots/${name}.png"
done

echo "🎉 All screenshots saved to screenshots/ directory"
