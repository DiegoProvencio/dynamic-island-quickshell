# Dynamic Island for Quickshell

A small Hyprland/Quickshell popup that appears when a Bluetooth audio device connects, shows its battery level when BlueZ provides it, and dismisses automatically.

## Run

```sh
qs -p /path/to/island-shell
```

To start it with Hyprland, add this to your Hyprland startup configuration:

```lua
hl.exec_cmd("qs -n -p /path/to/island-shell")
```

Replace `/path/to/island-shell` with this repository's location. The watcher requires `bluetoothctl`, Bash, and the standard `grep` and `sed` utilities. The QML uses Quickshell and Qt Quick.
