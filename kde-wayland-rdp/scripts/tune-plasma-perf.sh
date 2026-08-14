#!/bin/bash
# Lean compositor settings for software/vgem + KRdp.
set -e
U="${DESKTOP_USER:-kdeuser}"
export HOME="${HOME:-/home/$U}"
export XDG_CONFIG_HOME="${HOME}/.config"
if [ "$(id -u)" = 0 ]; then
  exec runuser -u "$U" -- env HOME="/home/$U" "$0" "$@"
fi
kwriteconfig6 --file kwinrc --group Compositing --key Enabled true
kwriteconfig6 --file kwinrc --group Compositing --key LatencyPolicy ExtremelyLow
kwriteconfig6 --file kwinrc --group Compositing --key WindowsBlockCompositing true
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key overviewEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key windowviewEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key slideEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key fadingpopupsEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key loginEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key logoutEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key maximizeEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key scaleEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key fullscreenEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key zoomEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key tileseditorEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key shakecursorEnabled false
kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0
kwriteconfig6 --file plasmarc --group PlasmaToolTips --key Delay -- -1
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 0
kwriteconfig6 --file plasma-welcomerc --group General --key ShouldShow false
kwriteconfig6 --file kwinrc --group Windows --key ElectricBorderTiling false
kwriteconfig6 --file kwinrc --group Windows --key SeparateScreenFocus false
echo "tuned $HOME/.config/kwinrc"
