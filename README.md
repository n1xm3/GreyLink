---

# GreyLink

GreyLink automates BepInEx and message hook installation required for GreyBel-VS to import and build GreyScript directly into Grey Hack.

---

## Disclaimer
GreyLink is NOT afffiliated with:
- Grey Hack
- GreyBel-VS
- BepInEx
- GreyHackMessageHook.dll

Use at your own discretion.

---

## What GreyLink Does

GreyLink:

- Detects your Steam installation
- Locates your Grey Hack game directory
- Downloads the correct BepInEx build (x86 or x64)
- Configures `run_bepinex.sh`
- Installs the required `GreyHackMessageHook.dll`
- Provides the correct Steam launch option configuration

After running GreyLink, only one manual step remains: setting the Steam launch options.

---

## What This Project Is Not

GreyLink is:

- Not a fork of BepInEx
- Not a fork of GreyBel-VS
- Not a mod manager
- Not a replacement launcher

It is strictly an automation and integration tool for Linux users.

---

## Requirements

- Linux system
- Steam installed
- Grey Hack installed
- `curl`
- `unzip`
- Optional: `zenity` (used only if automatic Steam detection fails)

---

## Platform Support

GreyLink supports **native Linux builds of Grey Hack**:

- x86_64
- x86

GreyLink does **not** currently support:

- Proton
- Windows builds (`.exe`)
- macOS

Support for additional platforms may be considered in the future.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/n1xm3/GreyLink.git
cd GreyLink
```
Make the installer executable:
```bash
chmod u+x install.sh
```
Run the installer:
```bash
./install.sh
```
---

## Final Manual Step (Required)
1. Open Steam
2. Righ-click on Grey Hack
3. Click Properties
4. Go to Launch Options
5. Paste the launch option text, provided by the script after it's finished

---

## Uninstalling
GreyLink includes an uninstall script to remove installed components.
To uninstall:
```bash
chmod u+x uninstall.sh
./uninstall.sh
```
The uninstaller will:
- remove `BepInEx` directory and all of its contents, which includes `GreyHackMessageHook.dll`
- remove `run_bepinex.sh`
- remove `libdoorstop.so`
- remove `.doorstop_version`

---

## Components Installed
GreyLink downloads and installs:

## BepInEx
- Version: 6.0.0-pre.2
- License: GNU LGPL-2.1
- Source: https://github.com/BepInEx/BepInEx

## GreyHackMessageHook.dll
- Used by GreyBel-VS to import and build code
- License: Unknown
- Download source referenced by GreyBel-VS

GreyLink does not modify upstream projects beyond necessary configuration.

---

## How It Works

GreyLink:
1. Detects executable architecture (x86 or x86_64)
2. Downloads the appropriate BepInEx build
3. Extracts and configures required files
4. Initializes BepInEx once
5. Installs the GreyBel message hook into:
`BepInEx/plugins`

---

## License
GreyLink is licensed under the MIT license.

Downloaded components are licensed under their own respective licenses.
