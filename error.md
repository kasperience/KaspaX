I was trying to run this command on target linux machine with arch
linux installed first script ./install.sh went well but the second
not, we simply have hardcoded my private paths on public repo...
[[[[kasperience@archlinux install]$ ./install-kaspa-apps.sh

kaspa-auth directory not found

kdapp-wallet directory not found

Installing systemd service files...
cp: cannot stat '<repo>/hyprland-sddm-config/config/systemd/user/kaspa-auth.service': No such file or directory

Reloading systemd user services...

All Kaspa applications installed successfully!]]] The mentioned
script is in hyprland-sddm-config/install/install-kaspa-apps.sh.
It was modified to use repo-relative paths and the apps under applications/kdapps.
