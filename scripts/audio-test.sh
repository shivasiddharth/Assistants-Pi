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

YES_ANSWER=1
NO_ANSWER=2
QUIT_ANSWER=3
parse_user_input()
{
  if [ "$1" = "0" ] && [ "$2" = "0" ] && [ "$3" = "0" ]; then
    return
  fi
  while [ true ]; do
    Options="["
    if [ "$1" = "1" ]; then
      Options="${Options}y"
      if [ "$2" = "1" ] || [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$2" = "1" ]; then
      Options="${Options}n"
      if [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$3" = "1" ]; then
      Options="${Options}quit"
    fi
    Options="$Options]"
    read -p "$Options >> " USER_RESPONSE
    USER_RESPONSE=$(echo $USER_RESPONSE | awk '{print tolower($0)}')
    if [ "$USER_RESPONSE" = "y" ] && [ "$1" = "1" ]; then
      return $YES_ANSWER
    else
      if [ "$USER_RESPONSE" = "n" ] && [ "$2" = "1" ]; then
        return $NO_ANSWER
      else
        if [ "$USER_RESPONSE" = "quit" ] && [ "$3" = "1" ]; then
          printf "\nGoodbye.\n\n"
          exit
        fi
      fi
    fi
    printf "Please enter a valid response.\n"
  done
}
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
echo "First let's test the speaker output. Are you ready?"
parse_user_input 1 1 0
USER_RESPONSE=$?
if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
  echo ""
  echo ""
  echo "=============Testing Speaker output============="
  speaker-test -t wav -l 2
fi
echo ""
echo ""
if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
  exit
fi
echo "Did you hear the audio from speaker?"
parse_user_input 1 1 0
USER_RESPONSE=$?
if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
  echo ""
  echo ""
  echo "Great!! Proceeding to test the microphones......"
  echo ""
  echo ""
  echo "A 10 second audio sample will be recorded for testing. Are you ready?"
  parse_user_input 1 1 0
  USER_RESPONSE=$?
  if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
    echo "Select your audio config that you used:"
    select_option mic AIY-HAT-or-CUSTOM-HAT USB-DAC-or-USB-SOUNDCARD-or-USB-MIC
    if [ $mic = AIY-HAT-or-CUSTOM-HAT ]; then
      echo "=============Recording Mic Audio Sample============="
      arecord -d 10 -D hw:0,0 -r 48000 -f S32_LE -c2 /home/pi/mic-test.wav
      echo ""
    elif [ $mic = USB-DAC-or-USB-SOUNDCARD-or-USB-MIC ];then
      echo "=============Recording Mic Audio Sample============="
      arecord -d 10 -D hw:1,0 -r 16000 -f S16_LE -c1 /home/pi/mic-test.wav
      echo ""
    fi
    echo "Finished recording the samples."
    echo ""
    echo "Playing back the recorded audio sample......"
    echo ""
    aplay /home/pi/mic-test.wav
    echo "Did you hear the recorded audio sample?"
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      echo ""
      echo ""
      echo "Great!! Proceed to installing the voice assistants...."
      echo ""
      echo ""
      exit
    fi
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      echo "Execute arecord -l in terminal and verify the card id with the ones mentioned in asound.conf file and .asoundrc file. Exiting..."
      exit
    fi
  fi
fi
if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
  echo "Execute aplay -l in terminal and verify the card id with the ones mentioned in asound.conf file and .asoundrc file. Exiting..."
  exit
fi
