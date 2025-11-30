# https://guekka.github.io/nixos-server-1/
# https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/

gparted
sudo mount /dev/disk/by-label/Notroot /mnt
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/persist
sudo btrfs subvolume create /mnt/workshop

#umount /mnt

export DISK=/dev/nvme0n1p
sudo mount -t tmpfs none /mnt

mkdir /mnt/nix
sudo mount -o subvol=nix,noatime "$DISK"2 /mnt/nix

mkdir /mnt/persist
sudo mount -o subvol=persist,noatime "$DISK"2 /mnt/persist

mkdir /mnt/workshop
sudo mount -o subvol=workshop,noatime "$DISK"2 /mnt/workshop

mkdir /mnt/boot
sudo mount "$DISK"1 /mnt/boot

nixos-install --no-root-passwd

# After logging into new system don't generate a hardware config and pull relevant lines
#nixos-generate-config --root /mnt