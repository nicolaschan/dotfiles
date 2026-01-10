# Remote Disk Decryption via SSH during initrd

This module enables an SSH server in the initrd (early boot) so you can remotely unlock encrypted disks.

## Setup

### 1. Generate a dedicated initrd host key on the target machine

```bash
sudo mkdir -p /etc/secrets/initrd
sudo ssh-keygen -t ed25519 -f /etc/secrets/initrd/ssh_host_ed25519_key -N ""
```

### 2. Sign the host key with your CA (on the machine with the CA private key)

```bash
ssh-keygen -s /path/to/ca-private-key \
  -I <hostname>-initrd \
  -h \
  -n <hostname>,<hostname>.local,<hostname>.zeromap.net \
  /etc/secrets/initrd/ssh_host_ed25519_key.pub
```

### 3. Copy the certificate back to the target machine

```bash
scp ssh_host_ed25519_key-cert.pub <hostname>:/etc/secrets/initrd/
```

### 4. Find your network driver (on the target machine)

```bash
lspci -k | grep -A3 -i ethernet
```

Add the driver module name to `boot.initrd.availableKernelModules` in your system configuration. Common drivers: `r8169`, `igc`, `e1000e`, `alx`, `igb`

### 5. Rebuild NixOS

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Usage: Unlocking the Disk

When the machine boots with an encrypted disk:

### 1. SSH into the machine (as root)

```bash
ssh root@<hostname>
```

### 2. Unlock the disk

You'll be dropped into a minimal shell. To unlock the disk and continue boot, run the `cryptsetup-askpass` script which reads passphrases from stdin:

```bash
cryptsetup-askpass
```

Then type your LUKS passphrase and press Enter.

Alternatively, you can echo the passphrase directly (less secure, visible in shell history):

```bash
echo -n "your-passphrase" > /crypt-ramfs/passphrase
```

### 3. Boot continues

After entering the correct passphrase, the disk will unlock and boot will continue. Your SSH connection will be terminated as the initrd hands off to the real system.

### 4. Reconnect

Wait a moment, then SSH in normally to the fully booted system.

## Troubleshooting

- **SSH connection refused**: The network driver may not be loaded. Check that `boot.initrd.availableKernelModules` includes your NIC driver.

- **Host key not trusted**: Ensure the certificate was signed correctly and the hostname matches one of the principals in the certificate.

- **Finding available commands**: In the initrd shell, run `help` or check `/bin`
