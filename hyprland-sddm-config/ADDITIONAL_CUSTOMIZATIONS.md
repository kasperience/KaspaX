# Additional Customizations for Lean Hyprland Setup

## Keybinding Customizations

We've customized the keybindings to remove any Omarchy-specific applications and focus on standard Linux tools:

1. **Removed Omarchy-specific applications**:
   - Removed references to `omarchy-menu`, `omarchy-webapp-install`, etc.
   - Replaced with standard applications like `rofi`, `thunar`, `firefox`

2. **Added useful system actions**:
   - `SUPER + L` - Lock screen with swaylock
   - `SUPER + SHIFT + L` - Lock session with loginctl
   - `SUPER + Backspace` - Suspend system
   - `SUPER + SHIFT + Backspace` - Hibernate system
   - `SUPER + Delete` - Power off system
   - `SUPER + SHIFT + Delete` - Reboot system

3. **Enhanced media controls**:
   - Added screenshot keybindings with `grim` and `slurp`
   - Added screen recording with `wf-recorder`
   - Added clipboard management with `clipman`

4. **Application launcher**:
   - `SUPER + Space` - Application launcher (rofi -show drun)
   - `SUPER + SHIFT + Space` - Run command (rofi -show run)

## Additional Tools Added

We've added the following tools to provide a complete, lean experience:

1. **rofi** - Application launcher and dmenu replacement
2. **swaylock** - Screen locker
3. **clipman** - Clipboard manager
4. **wf-recorder** - Screen recording tool

## Configuration Files Added

We've created configuration files for the new tools:

1. **clipman.conf** - Configuration for clipboard manager
2. **config.rasi** - Configuration for rofi
3. **swaylock config** - Configuration for screen locker

## Installation Script Updates

We've updated the installation script to:

1. Install the additional packages
2. Create configuration directories for the new tools
3. Copy the configuration files for the new tools

## Benefits of These Changes

1. **Lean Setup**: Removed all Omarchy-specific applications and replaced them with standard Linux tools
2. **Standard Tools**: Using widely adopted tools like rofi, swaylock, and clipman
3. **Complete Experience**: Added all necessary tools for a functional desktop environment
4. **Customizable**: All tools have configuration files that can be easily modified
5. **Documented**: Clear keybindings that are easy to understand and modify