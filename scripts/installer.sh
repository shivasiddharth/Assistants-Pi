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

sed -i 's/__USER__/'${USER}'/g' ${GIT_DIR}/systemd/alexa.service

sed -i 's/__USER__/'${USER}'/g' ${GIT_DIR}/systemd/mycroft.service

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
echo "=============Starting Assistant Installer=============="
echo ""
echo "From the list below, choose your option for installation: "
select_option assistants Google-Assistant Alexa Mycroft All
echo ""
if [ "$assistants" = "All" ]; then
  echo "You have chosen to install all the assistants, Google Assistant, Alexa and Mycroft"
else
  echo "You have chosen to install $assistants"
fi

case $assistants in
  Alexa)
  echo ""
  echo "=========================Installing Amazon Alexa================================"
  cd ${GIT_DIR}/Alexa/
  sudo chmod +x ./setup.sh
  sudo chmod +x ./pi.sh
  sudo ./setup.sh
  sudo chmod +x ./test.sh
  sudo chmod +x ./startsample.sh
  echo ""
  echo ""
  echo "========================Testing Alexa Installation========================"
  sudo ./test.sh
  echo "========================Finished Installing Amazon Alexa========================"
  echo ""
  echo "After that, proceed to step-9 mentioned in the README doc to set the assitsant to auto start on boot."
  ;;
  Google-Assistant)
  echo "Have you downloaded the credentials file, and placed it in /home/pi/ directory?"
  parse_user_input 1 1 0
  USER_RESPONSE=$?
  if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
    echo "=============Starting Google Assistant Installer============="
    cd /home/${USER}/
    git clone https://github.com/shivasiddharth/GassistPi
    sudo chmod +x /home/${USER}/GassistPi/scripts/gassist-installer.sh
    sudo /home/${USER}/GassistPi/scripts/gassist-installer.sh
    sudo cp /home/${USER}/GassistPi/systemd/gassistpi.service  ${GIT_DIR}/systemd/gassistpi.service
    echo ""
    echo ""
    echo "Finished installing Google Assistant....."
  elif ["$USER_RESPONSE" = "$NO_ANSWER" ]; then
    echo "Download the credentials file, , place it in /home/pi/ directory and start the installer again.."
    exit
  fi
  echo ""
  echo "===============Finished Installing Google Assistant==========="
  echo ""
  echo "After that, proceed to step-9 mentioned in the README doc to set the assitsants to auto start on boot."
  exit
  ;;
  Mycroft)
  echo ""
  echo "=========================Installing Mycroft================================"
  cd /home/${USER}/
  git clone https://github.com/shivasiddharth/mycroft-core
  cd mycroft-core
  bash dev_setup.sh
  echo ""
  echo "========================Finished Installing Mycroft========================"
  echo ""
  echo "After that, proceed to step-9 mentioned in the README doc to set the assitsant to auto start on boot."
  ;;
  All)
  echo ""
  echo "=========================Installing Amazon Alexa================================"
  cd ${GIT_DIR}/Alexa/
  sudo chmod +x ./setup.sh
  sudo chmod +x ./pi.sh
  sudo ./setup.sh
  sudo chmod +x ./test.sh
  sudo chmod +x ./startsample.sh
  echo "========================Testing Alexa Installation========================"
  sudo ./test.sh
  echo ""
  echo ""
  echo "===========Finished Installing Alexa. Proceeding to install Mycroft=========="
  echo ""
  echo ""
  echo "=========================Installing Mycroft================================"
  cd /home/${USER}/
  git clone https://github.com/shivasiddharth/mycroft-core
  cd mycroft-core
  bash dev_setup.sh
  echo ""
  echo "===========Finished Installing Alexa and Mycroft. Proceeding to install Google Assistant=========="
  echo ""
  echo "Have you downloaded the credentials file, and placed it in /home/pi/ directory?"
  echo ""
  echo ""
  parse_user_input 1 1 0
  USER_RESPONSE=$?
  if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
    echo "=============Starting Google Assistant Installer============="
    cd /home/${USER}/
    git clone https://github.com/shivasiddharth/GassistPi
    sudo chmod +x /home/${USER}/GassistPi/scripts/gassist-installer.sh
    sudo /home/${USER}/GassistPi/scripts/gassist-installer.sh
    sudo cp /home/${USER}/GassistPi/systemd/gassistpi.service  ${GIT_DIR}/systemd/gassistpi.service 
    echo ""
    echo "Finished installing Google Assistant....."
    echo ""
    echo "After that, proceed to step-9 mentioned in the README doc to set the assitsants to auto start on boot."
  elif ["$USER_RESPONSE" = "$NO_ANSWER" ]; then
    echo "Download the credentials file, , place it in /home/pi/ directory and start the installer again.."
    exit
  fi
  ;;
esac
