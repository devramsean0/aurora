if [ $(whoami) != 'root' ]; then
  echo "You are not ROOT, try running sudo ./setup2.sh";
  exit
fi
read -p "Target Config (ex: gaius) " config
  echo "Partitioning"
  lsblk
  # Create Partitions
  read -p "Which Drive? (ex: sda) " drive
  parted /dev/$drive -- mklabel gpt
  parted /dev/$drive -- mkpart root ext4 512MB -8GB
  parted /dev/$drive -- mkpart swap linux-swap -8GB 100%
  parted /dev/$drive -- mkpart ESP fat32 1MB 512MB
  parted /dev/$drive -- set 3 esp on
  echo "Formatting"

  drive1="$drive"1
  drive2="$drive"2
  drive3="$drive"3

  # Setup Encryption
  cryptsetup luksFormat /dev/$drive1
  cryptsetup open /dev/$drive1 cryptroot

  mkfs.ext4 -L nixos /dev/mapper/cryptroot
  mkswap -L swap /dev/$drive2
  mkfs.fat -F 32 -n boot /dev/$drive3

  # Mount Drives
  echo "Mounting"
  mount /dev/disk/by-label/nixos /mnt
  mkdir -p /mnt/boot
  mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

  swapon /dev/$drive2

  # Install NixOS
  mkdir -p /mnt/etc
  mkdir -p /config
  chmod 777 /config
  git clone https://github.com/devramsean0/aurora /config
  ln -s /config /mnt/etc/nixos

  if [ -d /config ]; then
    nixos-install --flake /config#$config;
  else
    echo "NixOS Config not found!";
    exit
  fi
  echo "Done, reboot."