#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

tee /usr/share/libalpm/hooks/package-cleanup.hook > /dev/null << 'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleaning up package cache...
Depends = coreutils
When = PostTransaction
Exec = /usr/bin/rm -rf /var/cache/pacman/pkg
EOF

pacman -Syu --noconfirm
pacman-key --init

# Import the repository key
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
# Sign the repository key
pacman-key --lsign-key F3B607488DB35A47

pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-22-1-any.pkg.tar.zst'

cat <<EOF > /tmp/cachyos-repos
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist

EOF

cat /etc/pacman.conf
cat /etc/pacman.conf >> /tmp/cachyos-repos

mv /tmp/cachyos-repos /etc/pacman.conf

packages=(
  base
  dracut

  linux-cachyos-bore
  linux-cachyos-bore-headers
  linux-cachyos-bore-nvidia

  linux-firmware
  ostree
  systemd
  btrfs-progs
  e2fsprogs
  xfsprogs
  binutils
  dosfstools
  skopeo
  dbus
  dbus-glib
  glib2
  shadow
)


pacman -Sy --noconfirm pacman
pacman -S --noconfirm "${packages[@]}"

mkinitcpio -P
echo "::endgroup::"
