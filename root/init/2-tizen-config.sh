#!/bin/bash

set -e

printf "# Step 2: Configuring Tizen SDK\n\n"

TIZEN_CERT_PATH="/home/jellyfin/tizen-studio-data/keystore/author"
TIZEN_CERT_FULL_PATH="$TIZEN_CERT_PATH/$TIZEN_CERT_FILE_NAME.p12"
TIZEN_CERT_PWD_FULL_PATH="$TIZEN_CERT_PATH/$TIZEN_CERT_FILE_NAME.pwd"
export TIZEN_BIN_PATH="/home/jellyfin/tizen-studio/tools/ide/bin"
TIZEN_CA_CERT_PWD_FULL_PATH="/home/jellyfin/tizen-studio-data/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.pwd"

source ~/.bashrc

printf "## Generating Tizen certificate\n"

if [ -f "$TIZEN_CERT_FULL_PATH" ]; then
  printf "Tizen certificate already exists. Skipping generation.\n"
else
  mkdir -p $TIZEN_CERT_PATH
  $TIZEN_BIN_PATH/tizen certificate -a $TIZEN_CERT_NAME -p $TIZEN_CERT_PASSWORD -c $TIZEN_YOUR_COUNTRY -ct $TIZEN_YOUR_CITY -o $TIZEN_YOUR_ORGANISATION -n "$TIZEN_YOUR_NAME" -e "$TIZEN_YOUR_EMAIL" -f $TIZEN_CERT_FILE_NAME -- $TIZEN_CERT_PATH
fi

printf "## Creating Tizen profile\n"

if $TIZEN_BIN_PATH/tizen security-profiles list | tail -n +3 | grep -q "$TIZEN_YOUR_NAME"
then
  printf "Tizen security profile already exists.\n"
  printf "Adding passwords for existing certificates to keyring.\n"

  echo -n "$TIZEN_CERT_PASSWORD" | secret-tool store \
    --label="Tizen Studio password for tizencert" \
    service '"tizen-studio"' \
    username "keyfile $TIZEN_CERT_PWD_FULL_PATH tool certificate-manager"

  echo -n "tizenpkcs12passfordsigner" | secret-tool store \
    --label="Tizen Studio password for CA Cert" \
    service '"tizen-studio"' \
    username 'keyfile /home/jellyfin/tizen-studio-data/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.pwd tool certificate-manager'
else
  tizen security-profiles add -n "$TIZEN_YOUR_NAME" -a $TIZEN_CERT_FULL_PATH -p $TIZEN_CERT_PASSWORD -A
fi

printf "## Configuring Tizen CLI\n"

$TIZEN_BIN_PATH/tizen cli-config "profiles.path=/home/jellyfin/tizen-studio-data/profile/profiles.xml"

/init/3-build.sh "$@"
