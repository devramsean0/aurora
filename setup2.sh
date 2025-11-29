if [ $(whoami) != 'root' ]; then
  echo "You are not ROOT, try running sudo ./setup2.sh";
  exit
fi
read -p "Target Config (ex: gaius) " config
echo "Partitioning"
lsblk
# Create Partitions
read -p "Which Drive? (ex: sda or /dev/sda or nvme0n1) " drive

# normalize to full path (/dev/...) if user passed short name
if [[ "$drive" != /dev/* ]]; then
  drive="/dev/$drive"
fi

# create GPT and three partitions: root, swap, ESP
parted "$drive" -- mklabel gpt
parted "$drive" -- mkpart root ext4 512MB -8GB
parted "$drive" -- mkpart swap linux-swap -8GB 100%
parted "$drive" -- mkpart ESP fat32 1MB 512MB
parted "$drive" -- set 3 esp on

# Name partitions so that /dev/disk/by-partlabel/<name> will exist
parted "$drive" name 1 encryptedroot || true
parted "$drive" name 2 swap || true
parted "$drive" name 3 boot || true

echo "Formatting"

# Partition name suffix: nvme and mmcblk devices use 'p' before the number
if [[ "$drive" == *"nvme"* || "$drive" == *"mmcblk"* ]]; then
  suf="p"
else
  suf=""
fi

drive1="${drive}${suf}1"
drive2="${drive}${suf}2"
drive3="${drive}${suf}3"

# Setup Encryption (LUKS) on partition 1, open as cryptroot
cryptsetup luksFormat "$drive1" --label encryptedroot
cryptsetup open "$drive1" cryptroot

# Create filesystems on the decrypted root, swap and EFI
mkfs.ext4 -L nixos /dev/mapper/cryptroot
mkswap -L swap "$drive2"
mkfs.fat -F 32 -n boot "$drive3"

# Mount Drives
echo "Mounting"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

swapon "$drive2"

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
