**For Augment reset tool, click here: [https://github.com/bunnysayzz/augment-reset.git](https://github.com/bunnysayzz/augment-reset.git)**

# Qoder Reset Tools

> Mac apps: [macbunny.co](http://macbunny.co)

## ⚠️ **IMPORTANT NOTICE** ⚠️

> **✨ Use a fingerprint browser to register after resetting Qoder!**
> 
> **Why?** Duplicate registrations may still be recognized due to browser cache or fingerprinting, even after resetting Qoder's device identity.
> 
> **Solution:** Use a privacy-focused fingerprint browser like [Mullvad Browser](https://www.privacyguides.org/en/desktop-browsers/#mullvad-browser) to create completely new browser profiles with unique fingerprints.
> 
> **Download:** [Privacy Guides - Desktop Browsers](https://www.privacyguides.org/en/desktop-browsers/)

---

A powerful and compact shell script to completely reset and clean all Qoder application identity information from your system. Get Qoder from [https://qoder.com](https://qoder.com)

## 🚀 Features

- **Complete Identity Reset**: Removes all Qoder machine IDs, telemetry data, hardware fingerprints, and network traces
- **Cross-Platform Support**: Works on Windows, macOS, and Linux
- **Safe Confirmation**: Requires user confirmation before proceeding
- **Hardware Fingerprint Reset**: Generates fake hardware information to bypass detection
- **Chat History Management**: Option to preserve or clean chat history
- **Pure Bash Script**: No external dependencies required

## 🛠️ Installation

### Option 1: Clone Repository
```bash
git clone https://github.com/bunnysayzz/qoder-reset.git
cd qoder-reset
chmod +x qoder.sh
./qoder.sh
```

### Option 2: Direct Download (Copy-Paste)

#### For macOS/Linux:
```bash
curl -o qoder.sh https://raw.githubusercontent.com/bunnysayzz/qoder-reset/main/qoder.sh && chmod +x qoder.sh
./qoder.sh
```

#### For Windows (Git Bash/WSL):
```bash
curl -o qoder.sh https://raw.githubusercontent.com/bunnysayzz/qoder-reset/main/qoder.sh && chmod +x qoder.sh
./qoder.sh
```

#### For Windows (PowerShell):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/bunnysayzz/qoder-reset/main/qoder_reset_windows.ps1" -OutFile "qoder_reset_windows.ps1"
.\qoder_reset_windows.ps1
```

### Option 3: Windows Native Scripts (Easiest)

#### Windows Batch File (Double-click to run):
```cmd
# Just download and double-click
qoder_reset_windows.bat
```

#### Windows PowerShell:
```powershell
# Run in PowerShell
.\qoder_reset_windows.ps1
```

### Option 4: Manual Copy-Paste
1. Visit: https://raw.githubusercontent.com/bunnysayzz/qoder-reset/main/qoder.sh
2. Copy the entire content
3. Create a new file: `qoder.sh`
4. Paste the content and save
5. Make executable: `chmod +x qoder.sh`

## 🎯 Usage

```bash
./qoder.sh
```

The script will:
1. Display a beautiful ASCII art banner
2. Check if Qoder is running and ask you to close it
3. Show available reset operations
4. Ask about preserving chat history
5. Perform the selected reset process

## 🔥 **CRITICAL NEXT STEP AFTER RESET**

**⚠️ IMPORTANT:** After running the reset script, you MUST:

1. **Download Fingerprint Browser**: [Privacy Guides - Desktop Browsers](https://www.privacyguides.org/en/desktop-browsers/)
2. **Recommended Options**: Mullvad Browser, Firefox+Arkenfox, Brave
3. **Set as Default Browser**: Make it your primary browser
4. **Use for Qoder Signup**: Only use the fingerprint browser for new Qoder registration

**Why?** Even after resetting Qoder's device identity, your regular browser can still be fingerprinted and detected. Using a privacy-focused fingerprint browser ensures complete anonymity.

**Best Choice:** [Mullvad Browser](https://www.privacyguides.org/en/desktop-browsers/#mullvad-browser) provides the strongest anti-fingerprinting protection out of the box.

## 🔧 What Gets Reset

The tool resets the following Qoder identity information:

- **Machine ID**: Generates new machine identifiers and UUIDs
- **Telemetry Data**: Resets all tracking and analytics data
- **Hardware Fingerprints**: Creates fake hardware information
- **Cache Directories**: Removes all cache and temporary files
- **Identity Files**: Cleans network traces and identity data
- **SharedClientCache**: Resets language server connections
- **Network State**: Clears persistent network connections

## ⚠️ Important Notes

- **Close Qoder First**: Ensure Qoder is completely closed before running
- **Fresh Identity**: Qoder will recognize your device as new after reset
- **Get Qoder**: Download and install Qoder from [https://qoder.com](https://qoder.com)
- **Chat History**: Choose whether to preserve or clean chat data
- **System Restart**: Recommended after completion for best results

## 🖥️ Supported Operating Systems

- **Windows**: Windows 10/11 (Git Bash, WSL, PowerShell, or native batch file)
- **macOS**: macOS 10.14+
- **Linux**: Most distributions with bash

## 📁 File Locations Cleaned

- Qoder application support directory
- Machine ID and device identifier files
- Telemetry and tracking data
- Cache and temporary directories
- Hardware fingerprint files
- Network state and connection data
- Shared client cache directories

## 🔍 Troubleshooting

### Common Issues

**Permission Denied**
```bash
chmod +x qoder.sh
```

**Script Won't Run**
```bash
ls -la qoder.sh
bash qoder.sh
```

**Qoder Still Running**
```bash
# macOS
pkill -f Qoder

# Windows
taskkill /f /im Qoder.exe

# Linux
pkill -f Qoder
```

**Directory Not Found**
- Ensure Qoder is installed
- Run Qoder at least once to create configuration

## 🎮 Available Operations

1. **Complete Reset** - Performs all reset operations (recommended)
2. **Reset Machine ID** - Only resets machine identifiers
3. **Reset Telemetry** - Only resets telemetry data
4. **Clean Cache** - Only cleans cache directories
5. **Clean Identity Files** - Only cleans identity files
6. **Reset Hardware Fingerprints** - Only resets hardware info
7. **Exit** - Quit the script

## 🛡️ Safety Features

- **Process Detection**: Won't run if Qoder is active
- **Directory Validation**: Ensures Qoder directory exists
- **User Confirmation**: Asks before destructive operations
- **Error Handling**: Exits on critical errors
- **Root Warning**: Warns against running as root

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👨‍💻 Author

**bunnysayzz**

- GitHub: [@bunnysayzz](https://github.com/bunnysayzz)

## ⭐ Show your support

Give a ⭐️ if this project helped you!

---

**Disclaimer**: Use this tool at your own risk. Always backup important data before running system cleanup tools. This tool is for educational purposes only.
