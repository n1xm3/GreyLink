#!/usr/bin/env bash

set -euo pipefail
GAME_NAME="Grey Hack"
STEAM_ROOT=""
FOUND=""
DEST=""

# --------------------------------------------------
# 1. Detect Steam
# --------------------------------------------------
CANDIDATES=(
    "$HOME/.local/share/Steam"
    "$HOME/.steam/steam"
    "$HOME/.var/app/com.valvesoftware.Steam/data/Steam"
)
for path in "${CANDIDATES[@]}"; do
    if [ -d "$path/steamapps" ]; then
        STEAM_ROOT="$path"
        break
    fi
done
if [ -z "$STEAM_ROOT" ]; then
    echo "Steam installation not found."
    exit 1
fi
DEFAULT_PATH="$STEAM_ROOT/steamapps/common"
MATCH=$(find "$DEFAULT_PATH" -maxdepth 1 -type d -iname "$GAME_NAME" 2>/dev/null | head -n1)
if [ -n "$MATCH" ]; then
    FOUND="$MATCH"
else
    LIBFILE="$STEAM_ROOT/steamapps/libraryfolders.vdf"
    if [ -f "$LIBFILE" ]; then
        while read -r LIB; do
            CANDIDATE="$LIB/steamapps/common"
            MATCH=$(find "$CANDIDATE" -maxdepth 1 -type d -iname "$GAME_NAME" 2>/dev/null | head -n1)
            if [ -n "$MATCH" ]; then
                FOUND="$MATCH"
                break
            fi
        done < <(grep -oP '"path"\s*"\K[^"]+' "$LIBFILE")
    fi
fi
if [ -z "$FOUND" ]; then
    echo "$GAME_NAME installation not found."
    exit 1
fi
DEST="$FOUND"

# --------------------------------------------------
# 2. Confirm Removal
# --------------------------------------------------
echo
echo "GreyLink components will be removed from:"
echo "$DEST"
echo
read -p "Continue? (y/N): " ans
ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
[[ "$ans" != "y" && "$ans" != "yes" ]] && exit 0

# --------------------------------------------------
# 3. Remove Components
# --------------------------------------------------
echo "Removing BepInEx and GreyLink components..."
rm -rf \
    "$DEST/BepInEx" \
    "$DEST/changelog.txt" \
    "$DEST/.doorstop_version" \
    "$DEST/libdoorstop.so" \
    "$DEST/run_bepinex.sh"
echo "Cleanup complete."
echo
echo "If you previously set Steam launch options,"
echo "remove them manually in:"
echo "Steam → Grey Hack → Properties → Launch Options"