# Razer Battery Menu Bar

A lightweight macOS menu bar app that shows the battery level of a connected
wireless Razer mouse. When the charge drops below 20% it posts a low-battery
notification.

Supported devices include the Razer Viper Ultimate, Viper V3 Pro, Naga Pro,
Lancehead, Mamba and DeathAdder V2 Pro (wireless).

## Install

1. Download the latest `.dmg` from the
   [Releases](https://github.com/qdzsh/razer-battery-macos/releases) page.
2. Open the `.dmg` and drag the app into `Applications`.
3. The app is ad-hoc signed (not notarized), so on first launch macOS will
   block it. Open **System Settings > Privacy & Security**, scroll down and
   click **Open Anyway**. Alternatively run:
   ```
   xattr -dr com.apple.quarantine "/Applications/razer-battery-menu-bar.app"
   ```

To launch on login, add the app under System Settings > General > Login Items.

## Build

Requirements: macOS 15.1+ and a recent Xcode.

1. Clone this repository.
2. Open `razer-battery-menu-bar.xcodeproj` and build the `razer-battery-menu-bar`
   scheme.

The `librazermacos` driver is vendored under `battery-group/librazermacos`, so no
extra setup is needed.

## Credits

Battery communication is handled by the
[librazermacos](https://github.com/1kc/librazermacos) C library (GPLv2), with
added support for the Razer Viper V3 Pro. This project is licensed under the
GPLv2 — see `LICENSE`.
