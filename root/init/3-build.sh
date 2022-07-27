#!/bin/bash

set -e

if [ $RUN_BUILD == "true" ]
then
  printf "# Step 3: Starting Build\n\n"

  printf "## jellyfin-web\n"
  printf "### Getting source code\n"

  if [ -d "jellyfin-web" ]; then
    printf "Source code directory already exists.\n"
  else
    printf "Identifying download location of latest release.\n"
    
    jellyfin_web_latest_release_url=$(curl -s https://api.github.com/repos/jellyfin/jellyfin-web/releases/latest \
      | grep "zipball_url" \
      | awk '{ print $2 }' \
      | sed 's/,$//'       \
      | sed 's/"//g' )
    
    printf "Downloading latest release.\n"
    jellyfin_web_zip="jellyfin_web_release.zip"
    curl -s -L -o $jellyfin_web_zip $jellyfin_web_latest_release_url
    printf "Unzipping latest release.\n"
    unzip -q $jellyfin_web_zip
    mv *jellyfin-web-* jellyfin-web
    printf "Cleaning up.\n"
    rm $jellyfin_web_zip

    # git clone https://github.com/jellyfin/jellyfin-web.git
  fi

  cd jellyfin-web

  # printf "Fetching repo changes.\n"
  # git fetch

  # printf "Pulling latest changes.\n"
  # git pull

  printf "### Building\n"
  npm ci --no-audit

  cd ..

  printf "## jellyfin-web done\n"

  printf "## jellyfin-tizen\n"
  printf "### Getting source code\n"

  if [ -d "jellyfin-tizen" ]; then
    printf "Source code directory already exists.\n"
  else
    printf "Cloning git repo.\n"
    git clone https://github.com/jellyfin/jellyfin-tizen.git
  fi

  cd jellyfin-tizen

  printf "Fetching repo changes.\n"
  git fetch

  printf "Pulling latest changes.\n"
  git pull

  printf "### Building\n"
  export JELLYFIN_WEB_DIR=../jellyfin-web/dist
  npm ci --no-audit

  printf "## Packaging for Tizen\n"

  $TIZEN_BIN_PATH/tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock"
  $TIZEN_BIN_PATH/tizen package -t wgt -o .. -- .buildResult

  cd ..

  printf "\n# Build suceeded. You can find the Tizen package at data/Jellyfin.wgt\n\n"
else
  printf "# Step 3: Skipping Build\n\n"
fi

/init/4-deploy.sh "$@"
