#!/bin/bash


scripts_dir="$(dirname "${BASH_SOURCE[0]}")"
GIT_DIR="$(realpath $(dirname ${BASH_SOURCE[0]})/..)"

# make sure we're running as the owner of the checkout directory
RUN_AS="$(ls -ld "$scripts_dir" | awk 'NR==1 {print $3}')"
if [ "$USER" != "$RUN_AS" ]
then
    echo "This script must run as $RUN_AS, trying to change user..."
    exec sudo -u $RUN_AS $0
fi
clear

select_option()
{
  local _result=$1
  local ARGS=("$@")
  if [ "$#" -gt 0 ]; then
      while [ true ]; do
         local count=1
         for option in "${ARGS[@]:1}"; do
            echo "$count) $option"
            ((count+=1))
         done
         echo ""
         local USER_RESPONSE
         read -p "Please select an option [1-$(($#-1))] " USER_RESPONSE
         case $USER_RESPONSE in
             ''|*[!0-9]*) echo "Please provide a valid number"
                          continue
                          ;;
             *) if [[ "$USER_RESPONSE" -gt 0 && $((USER_RESPONSE+1)) -le "$#" ]]; then
                    local SELECTION=${ARGS[($USER_RESPONSE)]}
                    echo "Selection: $SELECTION"
                    eval $_result=\$SELECTION
                    return
                else
                    clear
                    echo "Please select a valid option"
                fi
                ;;
         esac
      done
  fi
}

echo ""
echo "Updating and Upgrading System........."
sudo apt-get update
echo ""
echo "Installing Git........"
sudo apt-get install -y git
echo ""
echo "Installing pulseaudio....."
sudo apt-get install pulseaudio
echo ""
echo "Installing screen...."
sudo apt-get install screen
echo ""
echo "Changing username in service files........."
sed -i 's/__USER__/'${USER}'/g' /home/${USER}/Assistants-Pi/systemd/alexa.service
sed -i 's/__USER__/'${USER}'/g' /home/${USER}/Assistants-Pi/systemd/google-assistant.service
echo ""
echo ""
echo "Installing Basic Requisites........."
sudo pip3 install pyyaml
pip3 install pyyaml
sudo pip3 install spidev
pip3 install spidev
sudo pip3 install gpiozero
pip3 install gpiozero
sudo pip3 install numpy
pip3 install numpy
echo ""
echo ""
echo "Select your audio and mic configuration: "
select_option audio AIY-HAT CUSTOM-VOICE-HAT USB-MIC-ON-BOARD-JACK USB-MIC-HDMI USB-SOUND-CARD-or-DAC RESPEAKER-HAT
echo ""
echo "You have chosen to use $audio audio configuration"
echo ""
case $audio in
    AIY-HAT)
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/AIY-HAT/scripts/configure-driver.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/AIY-HAT/scripts/configure-driver.sh
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/AIY-HAT/scripts/install-alsa-config.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/AIY-HAT/scripts/install-alsa-config.sh
        ;;
    CUSTOM-VOICE-HAT)
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/CUSTOM-VOICE-HAT/scripts/custom-voice-hat.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/CUSTOM-VOICE-HAT/scripts/custom-voice-hat.sh
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/CUSTOM-VOICE-HAT/scripts/install-i2s.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/CUSTOM-VOICE-HAT/scripts/install-i2s.sh
        ;;
    USB-MIC-ON-BOARD-JACK)
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/USB-MIC-JACK/scripts/usb-mic-onboard-jack.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/USB-MIC-JACK/scripts/usb-mic-onboard-jack.sh
        sudo amixer cset numid=3 1
        echo "Audio set to be forced through 3.5mm jack."
        ;;
    USB-MIC-HDMI)
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/USB-MIC-HDMI/scripts/configure.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/USB-MIC-HDMI/scripts/configure.sh
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/USB-MIC-HDMI/scripts/install-usb-mic-hdmi.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/USB-MIC-HDMI/scripts/install-usb-mic-hdmi.sh
        echo "Audio set to be forced through HDMI."
        ;;
    USB-SOUND-CARD-or-DAC)
        sudo chmod +x /home/${USER}/Assistants-Pi/audio-drivers/USB-DAC/scripts/install-usb-dac.sh
        sudo /home/${USER}/Assistants-Pi/audio-drivers/USB-DAC/scripts/install-usb-dac.sh
	      ;;
    RESPEAKER-HAT)
        cd /home/${USER}/
        git clone https://github.com/shivasiddharth/seeed-voicecard
        cd ./seeed-voicecard/
        sudo ./install.sh
    	 ;;
esac
echo ""
echo "Audio configuration for $audio done."
echo ""
echo "System has been updated and audio configuration files installed."
echo ""
echo "Restart the Pi and run the audio-test.sh script to make sure that your Microphone and Speaker are working."
echo ""
