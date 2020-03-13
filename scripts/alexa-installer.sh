#!/bin/bash

set -o errexit

scripts_dir="$(dirname "${BASH_SOURCE[0]}")"
GIT_DIR="$(realpath $(dirname ${BASH_SOURCE[0]})/..)"

# make sure we're running as the owner of the checkout directory
RUN_AS="$(ls -ld "$scripts_dir" | awk 'NR==1 {print $3}')"
if [ "$USER" != "$RUN_AS" ]
then
    echo "This script must run as $RUN_AS, trying to change user..."
    exec sudo -u $RUN_AS $0
fi

echo "This could take a while grab a coffee or beer........."
cd ${GIT_DIR}/Alexa/
sudo chmod +x ./setup.sh
sudo chmod +x ./pi.sh
sudo chmod +x ./genConfig.sh
sudo ./setup.sh ./config.json
sudo chmod +x ./test.sh
sudo chmod +x ./startsample.sh
echo "Testing Alexa Installation............"
sudo ./test.sh
