function restore-dir {
  rm -ri $1"/*"
  mkdir -p $1
  cp -r "/tmp/workshop/btrfs-vol/persist-snapshot-2026-march-04"$1"/*" $1
}

function restore-file {
  cp -i "/tmp/workshop/btrfs-vol/persist-snapshot-2026-march-04"$1 $1
}

restore-dir /home/jit/.local/share/kactivitymanagerd
restore-file /home/jit/.config/kactivitymanagerdrc
restore-file /home/jit/.config/kactivitymanagerd-statsrc
restore-file /home/jit/.config/plasma-org.kde.plasma.desktop-appletsrc
restore-file /home/jit/.local/share/user-places.xbel
restore-file /home/jit/.local/share/user-places.xbel.bak
restore-file /home/jit/.local/share/user-places.xbel.tbcache
