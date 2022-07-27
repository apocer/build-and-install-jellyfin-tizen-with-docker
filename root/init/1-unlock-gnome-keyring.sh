#!/usr/bin/env bash

set -e

printf "# Step 1: Unlocking Gnome keyring\n\n"
# mkdir -p /home/jellyfin/.local/share
# rm -rf /home/jellyfin/.local/share/keyrings
# mkdir -p /home/jellyfin/tizen-studio-data/keyrings
# ln -s /home/jellyfin/tizen-studio-data/keyrings /home/jellyfin/.local/share

echo $DBUS_SESSION_BUS_ADDRESS > /home/jellyfin/DBUS_SESSION_BUS_ADDRESS

killall -q -9 "$(whoami)" gnome-keyring-daemon || echo '' > /dev/null

eval $(echo -n "$" | gnome-keyring-daemon --unlock | sed -e 's/^/export /')

/init/2-tizen-config.sh "$@"
