#!/usr/bin/env python3
"""
SkyUp Screenshot Tool

Takes screenshots of SkyUp web interfaces using Playwright (headless Chromium).
Requires: pip install playwright && playwright install chromium

Usage:
    python3 screenshots.py                  # Screenshot all services
    python3 screenshots.py open-webui       # Screenshot specific service
    python3 screenshots.py --list           # List available targets
"""

import os
import sys
import time
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("Error: Playwright is not installed.")
    print("Install it with:")
    print("  python3 -m pip install playwright")
    print("  python3 -m playwright install chromium")
    sys.exit(1)

# Project root is where this script lives
PROJECT_ROOT = Path(__file__).resolve().parent
SCREENSHOT_DIR = PROJECT_ROOT / "screenshots"
ENV_FILE = PROJECT_ROOT / ".env"

# Screenshot targets
TARGETS = {
    "open-webui": {
        "url": "http://127.0.0.1:8080",
        "description": "Open WebUI - AI Chat Interface",
        "wait_ms": 3000,
        "auth": None,
    },
    "n8n": {
        "url": "http://127.0.0.1:5678",
        "description": "n8n - Workflow Automation",
        "wait_ms": 3000,
        "auth": "basic",  # uses N8N_BASIC_USER / N8N_BASIC_PASSWORD from .env
    },
}

WIDTH = 1920
HEIGHT = 1080


def load_env(env_file: Path) -> dict:
    """Load key=value pairs from a .env file."""
    env = {}
    if not env_file.exists():
        return env
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" in line:
            key, _, value = line.partition("=")
            env[key.strip()] = value.strip()
    return env


def take_screenshot(name: str, target: dict, env: dict) -> bool:
    """Take a screenshot of a single target. Returns True on success."""
    url = target["url"]
    output_path = SCREENSHOT_DIR / f"{name}.png"
    print(f"  Capturing {name} ({url})...")

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                viewport={"width": WIDTH, "height": HEIGHT},
                ignore_https_errors=True,
            )

            # Set basic auth if needed
            if target["auth"] == "basic":
                user = env.get("N8N_BASIC_USER", "admin")
                password = env.get("N8N_BASIC_PASSWORD", "")
                if not password:
                    print(f"  Warning: N8N_BASIC_PASSWORD not found in .env, trying without auth")
                else:
                    context = browser.new_context(
                        viewport={"width": WIDTH, "height": HEIGHT},
                        ignore_https_errors=True,
                        http_credentials={"username": user, "password": password},
                    )

            page = context.new_page()
            page.goto(url, wait_until="networkidle", timeout=30000)
            page.wait_for_timeout(target["wait_ms"])
            page.screenshot(path=str(output_path), full_page=False)
            browser.close()

        size_kb = output_path.stat().st_size / 1024
        print(f"  Saved: {output_path.relative_to(PROJECT_ROOT)} ({size_kb:.0f} KB)")
        return True

    except Exception as e:
        print(f"  Failed to capture {name}: {e}")
        return False


def main():
    if "--list" in sys.argv:
        print("Available screenshot targets:")
        for name, target in TARGETS.items():
            print(f"  {name:15s} {target['url']:30s} {target['description']}")
        return

    # Determine which targets to capture
    requested = [a for a in sys.argv[1:] if not a.startswith("-")]
    if requested:
        targets = {k: v for k, v in TARGETS.items() if k in requested}
        unknown = set(requested) - set(TARGETS)
        if unknown:
            print(f"Unknown targets: {', '.join(unknown)}")
            print(f"Available: {', '.join(TARGETS)}")
            sys.exit(1)
    else:
        targets = TARGETS

    SCREENSHOT_DIR.mkdir(exist_ok=True)
    env = load_env(ENV_FILE)

    print(f"SkyUp Screenshot Tool")
    print(f"Output: {SCREENSHOT_DIR.relative_to(PROJECT_ROOT)}/")
    print(f"Resolution: {WIDTH}x{HEIGHT}")
    print()

    success = 0
    failed = 0
    for name, target in targets.items():
        if take_screenshot(name, target, env):
            success += 1
        else:
            failed += 1

    print()
    print(f"Done: {success} captured, {failed} failed")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
