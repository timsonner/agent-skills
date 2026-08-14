#!/bin/bash
# Create /dev/dri nodes when the kernel already has DRM minors in sysfs.
# Does not load modules and does not lift seccomp.
set -e
mkdir -p /dev/dri
for name in card0 renderD128; do
  sys="/sys/class/drm/$name/dev"
  node="/dev/dri/$name"
  if [ -e "$node" ] || [ ! -e "$sys" ]; then
    continue
  fi
  IFS=: read -r maj min < "$sys"
  mknod -m 666 "$node" c "$maj" "$min"
  echo "mknod $node c $maj $min"
done
ls -l /dev/dri 2>/dev/null || true
