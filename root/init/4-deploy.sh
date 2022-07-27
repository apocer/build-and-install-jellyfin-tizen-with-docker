#!/bin/bash

set -e

if [ $RUN_DEPLOY == "true" ]
then
  printf "# Step 4: Starting Deploy\n\n"

  printf "## Starting Smart Development Bridge server\n"
  sdb start-server

  printf "## Connecting to Samsung TV\n"
  sdb connect $SAMSUNG_TV_IP

  printf "## Getting TV Name\n"
  tv_name=$(sdb devices | tail -n +2 | sed 's/\t//g' | tr " " "\n" | tail -n 1)
  printf "TV's development name is $tv_name\n"
  
  printf "## Installing jellyfin to TV\n"
  tizen install -n Jellyfin.wgt -t $tv_name

  printf "## Disconnecting from Samsung TV\n"
  sdb disconnect $SAMSUNG_TV_IP

  printf "## Stopping Smart Development Bridge server\n"
  sdb kill-server

else
  printf "# Step 4: Skipping Deploy\n\n"
fi

exec "$@"
