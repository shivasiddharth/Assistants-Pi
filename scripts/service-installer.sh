#!/bin/bash

set -o errexit

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 1>&2
   exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
repo_path="$PWD"

for service in systemd/*.service; do
  sed "s:/home/pi/headless-alexa-avs-sample-app:${repo_path}:g" "$service" \
      > "/lib/systemd/system/$(basename "$service")"
done
