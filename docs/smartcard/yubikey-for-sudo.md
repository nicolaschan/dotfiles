# Yubikey for sudo use

Shortcut in `bin/@register-yubikey-sudo`

```fish
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
```

Then in the nix config we have

```nix
security.pam.services.sudo.u2fAuth = true;
```
