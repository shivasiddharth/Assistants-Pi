#!/bin/bash
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
echo ""
echo "First let's test the speaker output. Are you ready?"
parse_user_input 1 1 0
USER_RESPONSE=$?
if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
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
  echo "Great!! Proceeding to test the microphones......"
  echo ""
  echo ""
  echo "A 10 second audio sample will be recorded for testing. Are you ready?"
  parse_user_input 1 1 0
  USER_RESPONSE=$?
  if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
    echo "=============Recording Mic Audio Sample============="
    arecord -d10 -r16000 -c1 /home/pi/mic-test.wav
    echo ""
    echo "Finished recording the samples."
    echo ""
    echo "Playing back the recorded audio sample......"
    echo ""
    aplay /home/pi/mic-test.wav
    echo "Did you hear the recorded audio sample?"
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      echo "Great!! Proceed to installing the voice assistants...."
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
