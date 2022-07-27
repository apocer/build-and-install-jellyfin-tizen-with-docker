#!/usr/bin/env bash

set -e

printf "\n"
printf "# Step 0: Starting DBus session\n\n"

dbus-run-session /init/1-unlock-gnome-keyring.sh "$@"
