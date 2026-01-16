# Aurora
My Gen 3 nixos config!

## Overview of the machines
This config contains the configuration for 5 computers & servers.

### Maximus
My desktop computer, runs an AMD Ryzen 2nd Gen with a few TB of storage and 32GB of DDR4 RAM.

Configuration found [here](./systems/maximus/)

#### Rebuilding
Just run `sudo nixos-rebuild switch`

#### New Deployment
Boot into a liveusb of [install-iso](./systems/install-iso/) and then run /etc/setup.sh with an internet connection (only supports ethernet).

### Gaius
My Thinkpad/x86 laptop, runs an 8th gen intel processor with 16GB of DDR4 RAM and a 256GB SSD
Configuration found [here](./systems/gaius/)

#### Rebuilding
Just run `sudo nixos-rebuild switch`

#### New Deployment
Boot into a liveusb of [install-iso](./systems/install-iso/) and then run /etc/setup.sh with an internet connection (only supports ethernet).

### Titus
My M1 Macbook Air/aarm64 computer. Runs Nixos using asahi & MacOS ventura. Has 16GB of ram and 512GB of SSD

#### Rebuilding
Just run `sudo nixos-rebuild switch --impure` --impure is required for compliance with some binary blobs
#### New Deployment
Boot into MacOS and then run `curl https://alx.sh | sh` in a terminal.

Then follow [this nix-community guide](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md) and do the encryption stuff like normal

### Lucius
My reverse proxy/oracle VM, Runs on the Oracle Cloud Free ARM64 allocation.

Configuration found [here](./systems/lucius/)

#### Rebuilding
Just run `sudo nixos-rebuild switch`

#### New Deployment
Boot into a liveusb of [install-iso](./systems/install-iso/) and then run /etc/setup.sh with an internet connection (only supports ethernet).

### Scipio
### Agedius

## Installing on a computer
First, run `nix build #install-iso` on a computer with nix and nix flakes enabled, and then flash to a bootable iso.

After it boots to the terminal, connect it to an ethernet network or connect to wifi and then run `/etc/setup.sh`.

