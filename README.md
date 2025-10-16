# SoloCastControl

A simple Bash script for controlling the HyperX SoloCast USB microphone on Linux. It allows you to easily turn the microphone on/off, adjust volume levels, and check its status from the command line.  
SoloCastControl is ideal for automation tasks where microphone control needs to be scripted or triggered programmatically.

## Features

- **Turn microphone on/off**: Quickly enable or disable the microphone capture.
- **Toggle microphone state**: Switch between on and off with a single command.
- **Set volume**: Adjust the microphone volume to a specific percentage (0-100%).
- **Increase/Decrease volume**: Increment or decrement volume by 10% steps.
- **Get status**: Display the current microphone state (on/off) and volume level in percentage.
- **Fallback card selection**: If the SoloCast isn't detected, prompts for manual selection from available sound cards.
- **Customizable controls**: Override default ALSA control names via environment variables.
- **Error handling**: Checks for `amixer` availability and handles command failures gracefully.

## Requirements

- **Operating System**: Linux (tested on Arch / Debian-based systems like Manjaro / Ubuntu).
- **Dependencies**:
  - `alsa-utils` (for the `amixer` command).
  - `bash`, `grep`, `awk`, `sed` (usually pre-installed).

## Installation

### Option 1: Manual Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Mr-Precise/SoloCastControl
   cd SoloCastControl
   ```
2. Copy to a directory in your PATH (e.g., `/usr/bin` or `~/.local/bin`):
   ```bash
   sudo cp SoloCastControl.sh /usr/bin/solocastcontrol
   ```

### Option 2: Using Makefile
The repository includes a Makefile for easy installation.
1. Clone the repository as above.
2. Install:
   ```bash
   sudo make install
   ```
   This installs the script as `/usr/bin/solocastcontrol`. You can customize with:
   - `PREFIX=/usr` for system-wide installation.
   - ``DESTDIR=`pwd`/path`` for staging.

To uninstall:
```bash
sudo make uninstall
```

### Option 3: Debian Package
For Debian-based systems, you can build and install a `.deb` package.
1. Install build tools:
   ```bash
   sudo apt install dh-make debhelper devscripts lintian
   ```
2. Prepare the source (assuming you have the tarball or repository).
3. Build the package:
   ```bash
   debuild -us -uc
   ```
4. Install the resulting `.deb`:
   ```bash
   sudo dpkg -i ../solocastcontrol_1.0-1_all.deb
   ```

### Option 4: Arch Linux PKGBUILD Package

For Arch Linux users, a PKGBUILD file is included in the repository to build and install the script as a package (named `solocastcontrol-git`) using `makepkg`. This fetches the latest version from Git and installs it system-wide.

1. Install build dependencies if needed:
   ```
   sudo pacman -S --needed git base-devel
   ```
2. Build and install the package:
   ```
   makepkg -si
   ```
   - `-s`: Installs any missing dependencies automatically.
   - `-i`: Installs the built package.

## Usage

Run the script with one of the following commands:

```
solocastcontrol on          # Turn on microphone
solocastcontrol off         # Turn off microphone
solocastcontrol toggle      # Toggle microphone state
solocastcontrol set <0-100> # Set volume (e.g., solocastcontrol set 50)
solocastcontrol up          # Increase volume by 10%
solocastcontrol down        # Decrease volume by 10%
solocastcontrol get         # Get current status and volume
```

### Examples
- Turn on the microphone:
  ```
  solocastcontrol on
  ```
  Output: Microphone on (in green)

- Set volume to 75%:
  ```
  solocastcontrol set 75
  ```
  Output: Volume set to 75% (4224/5632)  # Values depend on your hardware

- Get status:
  ```
  solocastcontrol get
  ```
  Output:
  ```
  Microphone status: on  # In green if on, red if off
  Volume: 100% (5632/5632)
  ```

### Customization
- **Custom ALSA Controls**: If your microphone uses different control names, set environment variables:
  ```
  MIC_VOLUME_CONTROL="Capture Volume" MIC_SWITCH_CONTROL="Capture Switch" solocastcontrol get
  ```
- **Debugging**: If issues arise, check `amixer -c <card_id> controls` to verify control names.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for details.
