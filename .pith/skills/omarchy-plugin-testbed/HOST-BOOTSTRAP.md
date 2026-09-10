# Host bootstrap and VM creation

Run these commands in a host terminal:

```sh
sudo -A pacman -S --needed qemu-desktop libvirt virt-manager dnsmasq edk2-ovmf swtpm
sudo -A systemctl enable --now libvirtd
sudo -A usermod -aG libvirt "$USER"
```

Log out and back in so the `libvirt` group applies. Download the current Omarchy ISO from the official release page (`https://github.com/omacom/omarchy/releases`) and verify its SHA256 against the published checksum.

Create a VM with `--connect qemu:///session` (the user-session hypervisor avoids home-directory permission issues; use `qemu:///system` only when its storage permissions are configured). Configure:

- Name: `omarchy-plugin-testbed`
- 4 vCPU
- 8 GiB RAM
- 64 GiB dynamically allocated qcow2 disk
- UEFI firmware
- virtio disk and network
- SPICE display
- user-mode networking or the default libvirt network

Use virt-manager for the graphical install, or `virt-install` with `--connect qemu:///session`. Keep VM files under `~/.local/share/omarchy-plugin-testbed/images/` for the session hypervisor. After installation, install guest tools and plugin dependencies, then create the `plugin-ready` snapshot only after validation passes.

UEFI pflash currently prevents libvirt internal snapshots with the generated raw NVRAM file. For a reliable baseline, stop the VM and copy both the qcow2 disk and its NVRAM file. Create `clean-install.qcow2` and `clean-install_VARS.fd` beside the active images. Create `plugin-ready` only after guest tools, dependencies, and plugin validation pass.

Create `~/.config/omarchy-plugin-testbed/config.env` with values matching the VM and guest access method, for example:

```sh
LIBVIRT_URI=qemu:///session
VM_NAME=omarchy-plugin-testbed
BASELINE_SNAPSHOT=plugin-ready
CLEAN_SNAPSHOT=clean-install
BASELINE_IMAGE_DIR=/home/daniel/.local/share/omarchy-plugin-testbed/images
GUEST_PLUGIN_ROOT=$HOME/.config/omarchy/plugins
REPO_PATH=/home/daniel/Projects/omarchy-awake
PLUGIN_ID=io.github.danielmrdev.omarchy-awake
```

Do not use host paths, host SSH keys, or shared clipboard/file access unless deliberately configured. VM deletion, snapshot deletion, and disk deletion require explicit confirmation.
