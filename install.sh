#!/bin/bash

set -euo pipefail
GAME_NAME="Grey Hack"
BEPINEX_VERSION="6.0.0-pre.2"
STEAM_ROOT=""
FOUND=""
DEST=""
EXEC_NAME=""
GUI=true
HOOK_URL="https://gist.github.com/ayecue/b45998fa9a8869e4bbfff0f448ac98f9/raw/ff8d7b0cb18b1ecd5a833b053ca05cbc5670628c/GreyHackMessageHook.dll"
HOOK_FILE="GreyHackMessageHook.dll"
TMPDIR=$(mktemp -d)
HOOK_ARCHIVE="$TMPDIR/$HOOK_FILE"
trap 'rm -rf "$TMPDIR"' EXIT

# --------------------------------------------------
# 1. Detect zenity
# --------------------------------------------------
if ! command -v zenity >/dev/null 2>&1; then
    GUI=false
fi

# --------------------------------------------------
# 2. Steam detection
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
    if [ "$GUI" = true ]; then
        STEAM_ROOT=$(zenity --file-selection --directory --title="Select your Steam folder")
    else
        read -p "Enter path to your Steam folder: " STEAM_ROOT
    fi

    if [ ! -d "$STEAM_ROOT/steamapps" ]; then
        echo "Invalid Steam folder."
        exit 1
    fi
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
    if [ "$GUI" = true ]; then
        SELECTED=$(zenity --file-selection --directory --title="Select $GAME_NAME folder")
    else
        read -p "Enter path to $GAME_NAME folder: " SELECTED
    fi
    if [ -d "$SELECTED" ]; then
        FOUND="$SELECTED"
    fi
fi
if [ -z "$FOUND" ]; then
    echo "$GAME_NAME installation not found."
    exit 1
fi
DEST="$FOUND"
LAUNCH_CMD="\"$DEST/run_bepinex.sh\" || %command%"

# --------------------------------------------------
# 3. Detect executable architecture
# --------------------------------------------------
EXE64="$DEST/Grey Hack.x86_64"
EXE32="$DEST/Grey Hack.x86"
EXEWINE="$DEST/Grey Hack.exe"
if [ -f "$EXEWINE" ]; then
    echo "Windows version detected."
    echo "Please use BepInEx for Windows."
    exit 0
fi
if [ -f "$EXE64" ]; then
    FILE="BepInEx-Unity.Mono-linux-x64-${BEPINEX_VERSION}.zip"
    EXEC_NAME="Grey Hack.x86_64"
elif [ -f "$EXE32" ]; then
    FILE="BepInEx-Unity.Mono-linux-x86-${BEPINEX_VERSION}.zip"
    EXEC_NAME="Grey Hack.x86"
else
    echo "Unsupported or unknown executable."
    exit 1
fi
URL="https://github.com/BepInEx/BepInEx/releases/download/v${BEPINEX_VERSION}/${FILE}"
ARCHIVE="$TMPDIR/$FILE"

# --------------------------------------------------
# 4. Informed consent
# --------------------------------------------------
echo
echo "During install, your screen will blink as if your game is loading"
echo "this is normal and is due to initializing BepInEx"
echo
echo "This installer will download and install:"
echo "BepInEx ${BEPINEX_VERSION}."
echo "  License: GNU LGPL-2.1"
echo "  Source: https://github.com/BepInEx/BepInEx"
echo
echo "GreyHackMessageHook.dll"
echo "  License: unknown"
echo "  URL obtained from: https://github.com/ayecue/greybel-vs"
echo "  URL:"
echo "    https://gist.github.com/ayecue/b45998fa9a8869e4bbfff0f448ac98f9/raw/ff8d7b0cb18b1ecd5a833b053ca05cbc5670628c/GreyHackMessageHook.dll"
echo "  Source: unknown"
echo
read -p "Continue? (y/N): " ans
ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
[[ "$ans" != "y" && "$ans" != "yes" ]] && exit 0

# --------------------------------------------------
# 5. Download
# --------------------------------------------------
echo "downloading $ARCHIVE"
curl -fsSL -o "$ARCHIVE" "$URL"
if [ ! -s "$ARCHIVE" ]; then
    echo "Download failed."
    exit 1
fi
if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip is required but not installed."
    exit 1
fi
echo "downloading $HOOK_ARCHIVE"
curl -fsSL -o "$HOOK_ARCHIVE" "$HOOK_URL"
if [ ! -s "$HOOK_ARCHIVE" ]; then
    echo "Failed to download GreyHackMessageHook.dll"
    exit 1
fi

# --------------------------------------------------
# 6. Extract
# --------------------------------------------------
echo "installing BepInEx"
if ! unzip -o "$ARCHIVE" -d "$DEST" >/dev/null 2>&1; then
    echo "Extraction failed."
    exit 1
fi

# --------------------------------------------------
# 7. Configure and install
# --------------------------------------------------
RUN_SCRIPT="$DEST/run_bepinex.sh"
find "$DEST/BepInEx" -type d -exec chmod 755 {} \;
find "$DEST/BepInEx" -type f -exec chmod 644 {} \;
chmod 644 "$DEST/changelog.txt"
chmod 644 "$DEST/.doorstop_version"
chmod 644 "$DEST/libdoorstop.so"
chmod 755 "$RUN_SCRIPT"
sed -i '1s|^#!.*|#!/usr/bin/env bash|' "$RUN_SCRIPT"
sed -i "s/^executable_name=\".*\"/executable_name=\"$EXEC_NAME\"/" "$RUN_SCRIPT"
if ! (cd "$DEST" && ./run_bepinex.sh >/dev/null 2>&1 ); then
    echo "Initialization failed."
    exit 1
fi
echo
echo "Installation of BepInEx complete."

# --------------------------------------------------
# 8. Install GreyHackMessageHook.dll
# --------------------------------------------------
PLUGIN_DIR="$DEST/BepInEx/plugins"
mkdir -p "$PLUGIN_DIR"
echo "installing $HOOK_ARCHIVE"
if ! install -m 644 "$HOOK_ARCHIVE" "$PLUGIN_DIR/$HOOK_FILE"; then
    echo
    echo "ERROR: Failed to install $HOOK_FILE."
    echo
    echo "To manually install it:"
    echo "1. Download:"
    echo "   $HOOK_URL"
    echo
    echo "2. Copy it to:"
    echo "   $PLUGIN_DIR"
    echo
    echo "3. In Steam → Grey Hack → Properties → Launch Options"
    echo "   Copy and paste the following exactly:"
    echo
    echo "$LAUNCH_CMD"
    echo
    exit 1
fi
echo
echo "Installation complete!"
echo
echo "Final Step:"
echo "In Steam → Grey Hack → Properties → Launch Options"
echo "Copy and paste the following exactly:"
echo
echo "$LAUNCH_CMD"
echo
exit 0