---
name: omarchy-plugin-testbed
description: Use when developing, installing, validating, debugging, or resetting an Omarchy shell plugin in the local testbed VM.
invocation:
  model: true
  user: true
---

# Omarchy plugin testbed

Use the isolated Omarchy VM as the default target for plugin work. Keep the host unchanged except for the VM/libvirt layer.

## Configuration

Read `~/.config/omarchy-plugin-testbed/config.env` before acting. It defines the libvirt URI, VM name, repository path, guest plugin ID, and snapshot names. If it is missing, stop and report the host bootstrap command; do not guess paths.

## Guest access bootstrap

The testbed guest must be administrable before plugin work starts:

- Install and enable `qemu-guest-agent` and `sshd` from a guest terminal:
  `sudo pacman -S --noconfirm qemu-guest-agent openssh && sudo systemctl enable --now qemu-guest-agent sshd`.
- Set known test-only passwords interactively with `sudo passwd daniel` and, when root login is required, `sudo passwd root`. Never store or print the passwords in this skill, config, logs, or chat.
- Prefer QEMU Guest Agent for commands and health checks. SSH requires a host-forwarded port because the VM uses user-mode networking; configure and record the forward before relying on SSH.
- Verify access with `virsh -c "$LIBVIRT_URI" qemu-agent-command "$VM_NAME" '{"execute":"guest-info"}'` and an SSH connection through the configured host forward. Do not copy host secrets into the guest.
- If password setup fails through a pipeline, use `passwd` interactively; `sudo echo ... | chpasswd` does not run `chpasswd` with elevated privileges.

Completion: the guest agent responds, `sshd` is enabled and running, and the test user can authenticate through the configured access method.

## Workflow

1. **Observe.** Check that libvirt is reachable, the VM exists, and its state is known. Completion: record URI, VM name, and state.
2. **Start.** Start the VM only when it is shut off, then wait for the graphical guest session. Completion: the guest is running and reachable through the configured console/SSH method.
3. **Baseline.** Before a new test, confirm the selected baseline snapshot or baseline image exists. Restore only when explicitly requested or when the workflow says to reset. Completion: record the baseline identity.
4. **Install.** Prefer QEMU Guest Agent `guest-file-*` plus `guest-exec` to copy the checkout into the guest's `~/.config/omarchy/plugins/<plugin-id>`. Run Omarchy commands as `daniel` through a login shell so `OMARCHY_PATH` is set: `runuser -u daniel -- bash -lc 'omarchy-shell shell rescanPlugins && omarchy plugin enable <plugin-id>'`. Install an independent service from the guest checkout as `daniel` and verify it with `systemctl --user`. Completion: the guest contains the tested revision, the plugin is enabled, and its service is running when the plugin requires one.
5. **Verify.** Run the repository's validation commands on the host and guest where dependencies exist. Inspect Quickshell and user-service logs for failures; report missing guest tools separately from plugin failures. Completion: save command output and the tested commit/path; report every failed check.
6. **Checkpoint.** Create a named libvirt snapshot, or a stopped-VM disk/NVRAM baseline copy when UEFI pflash prevents internal snapshots. Completion: the checkpoint exists and its name/path is recorded.
7. **Reset/stop.** For a clean retry, stop guest processes and restore the named snapshot. Stop the VM when finished unless asked to leave it running. Completion: report the final VM state.

## Safety

- Treat VM deletion, snapshot deletion, disk deletion, and host package removal as destructive: ask for confirmation first.
- Ask before copying host secrets, SSH keys, browser data, or private repositories into the guest.
- Use one snapshot or baseline copy per meaningful state; never silently overwrite the configured baseline.
- Prefer guest-local project copies or a deliberate shared folder; record which was used.

## Omarchy plugin checks

For Quickshell plugins, run inside the guest:

```sh
omarchy plugin validate .
qmllint -I "$OMARCHY_PATH/shell" BarWidget.qml Panel.qml
```

Add project-specific checks from its `AGENTS.md`/README. For a systemd user service, also run its syntax/unit tests and inspect `systemctl --user status` and `journalctl --user -u <unit>`.

## Host bootstrap

Read `HOST-BOOTSTRAP.md` for one-time package installation and VM creation. It requires an interactive host terminal because it installs packages and enables libvirt.
