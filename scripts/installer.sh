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

#Check CPU architecture
if [[ $(uname -m|grep "armv7") ]] || [[ $(uname -m|grep "x86_64") ]]; then
	devmodel="armv7"
  echo ""
  echo "Your board is supported. Continuing.."
  echo ""
else
	devmodel="armv6"
  echo ""
  echo "Your board is not supported. Exiting..."
  echo ""
  exit 1
fi

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

clear
echo "Starting Assistant Installer.........."
echo ""
echo "From the list below, choose your option for installation: "
select_option assistants Google-Assistant Alexa Both
echo ""
if [ "$assistants" = "Both" ]; then
  echo "You have chosen to install both Google Assistant and Alexa"
else
  echo "You have chosen to install $assistants"
fi

case $assistants in
  Alexa)
  echo ""
  echo "Installing Amazon Alexa.........."
  echo ""
  sudo chmod +x ${GIT_DIR}/scripts/alexa-installer.sh
  sudo ${GIT_DIR}/scripts/alexa-installer.sh
  echo ""
  echo "Finished installing Alexa.........."
  echo ""
  ;;
  Google-Assistant)
  echo "Have you downloaded the credentials file, and placed it in /home/pi/ directory?"
  parse_user_input 1 1 0
  USER_RESPONSE=$?
  if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
    echo ""
    echo "Starting Google Assistant Installer.........."
    echo ""
    sudo chmod +x ${GIT_DIR}/scripts/gassist-installer.sh
    sudo ${GIT_DIR}/scripts/gassist-installer.sh
    echo ""
    echo "Finished installing Google Assistant.........."
    echo ""
    echo "After that, proceed to step-9 mentioned in the README doc to set the assitsants to auto start on boot."
  elif ["$USER_RESPONSE" = "$NO_ANSWER" ]; then
    echo "Download the credentials file, , place it in /home/pi/ directory and start the installer again."
    exit
  fi
  echo ""
  echo ""
  echo ""
  exit
  ;;
  Both)
  cd ${GIT_DIR}/Alexa/
  echo ""
  echo "Installing Amazon Alexa.........."
  echo ""
  sudo chmod +x ${GIT_DIR}/scripts/alexa-installer.sh
  sudo ${GIT_DIR}/scripts/alexa-installer.sh
  echo ""
  echo "Finished Installing Alexa. Proceeding to install Google Assistant"
  echo ""
  echo "Have you downloaded the credentials file, and placed it in /home/pi/ directory?"
  echo ""
  echo ""
  parse_user_input 1 1 0
  USER_RESPONSE=$?
  if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
    echo ""
    echo "Starting Google Assistant Installer.........."
    echo ""
    sudo chmod +x ${GIT_DIR}/scripts/gassist-installer.sh
    sudo ${GIT_DIR}/scripts/gassist-installer.sh
    echo ""
    echo "Finished installing Google Assistant.........."
    echo ""
    echo "After that, proceed to step-9 mentioned in the README doc to set the assitsants to auto start on boot."
  elif ["$USER_RESPONSE" = "$NO_ANSWER" ]; then
    echo "Download the credentials file, , place it in /home/pi/ directory and start the installer again.."
    exit
  fi
  ;;
esac
