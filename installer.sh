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
select_option assistants Google-Assistant Alexa Both
echo ""
if [ "$assistants" = "Both" ]; then
   echo "You have chosen to install both Google Assistant and Alexa"
else
   echo "You have chosen to install $assistants"
fi
if [ "$assistants" = "Both" ] || [ "$assistants" = "Alexa" ]; then
   git clone https://github.com/shivasiddharth/alexa-avs-sample-app
   echo ""
   echo ""
   read -r -p "Enter the Product Id given in the Amazon Developer portal: " productid
   echo ""
   read -r -p "Enter the Client Id given in the Amazon Developer portal: " clientid
   echo ""
   read -r -p "Enter the Client Secret given in the Amazon Developer portal: " clientsecret
   echo ""

   ProductID=$productid
   ClientID=$clientid
   ClientSecret=$clientsecret
   #-------------------------------------------------------
   # Pre-populated for testing. Feel free to change.
   #-------------------------------------------------------
   # Your Country. Must be 2 characters!
   Country='US'
   # Your state. Must be 2 or more characters.
   State='WA'
   # Your city. Cannot be blank.
   City='SEATTLE'
   # Your organization name/company name. Cannot be blank.
   Organization='AVS_USER'
   # Your device serial number. Cannot be blank, but can be any combination of characters.
   DeviceSerialNumber='123456789'
   # Your KeyStorePassword. We recommend leaving this blank for testing.
   KeyStorePassword=''
   Credential=""
   get_credential()
   {
     Credential=""
     read -p ">> " Credential
     while [ "${#Credential}" -lt "$1" ]; do
       echo "Input has invalid length."
       echo "Please try again."
       read -p ">> " Credential
     done
   }

   check_credentials()
   {
     clear
     echo "======Verifying AVS Credentials======"
     echo ""
     if [ "${#ProductID}" -eq 0 ] || [ "${#ClientID}" -eq 0 ] || [ "${#ClientSecret}" -eq 0 ]; then
       echo "At least one of the needed credentials (ProductID, ClientID or ClientSecret) is missing."
       echo ""
       echo ""
       echo "These values can be found here https://developer.amazon.com/edw/home.html, fix this now?"
       echo ""
       echo ""
       parse_user_input 1 0 1
     fi

     # Print out of variables and validate user inputs
     if [ "${#ProductID}" -ge 1 ] && [ "${#ClientID}" -ge 15 ] && [ "${#ClientSecret}" -ge 15 ]; then
       echo "ProductID >> $ProductID"
       echo "ClientID >> $ClientID"
       echo "ClientSecret >> $ClientSecret"
       echo ""
       echo ""
       echo "Is this information correct?"
       echo ""
       echo ""
       parse_user_input 1 1 0
       USER_RESPONSE=$?
       if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
         return
       fi
     fi

     clear
     # Check ProductID
     NeedUpdate=0
     echo ""
     if [ "${#ProductID}" -eq 0 ]; then
       echo "Your ProductID is not set"
       NeedUpdate=1
     else
       echo "Your ProductID is set to: $ProductID."
       echo "Is this information correct?"
       echo ""
       parse_user_input 1 1 0
       USER_RESPONSE=$?
       if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
         NeedUpdate=1
       fi
     fi
     if [ $NeedUpdate -eq 1 ]; then
       echo ""
       echo "This value should match your ProductID (or Device Type ID) entered at https://developer.amazon.com/edw/home.html."
       echo "The information is located under Device Type Info"
       echo "E.g.: RaspberryPi3"
       get_credential 1
       ProductID=$Credential
     fi

     echo "-------------------------------"
     echo "ProductID is set to >> $ProductID"
     echo "-------------------------------"

     # Check ClientID
     NeedUpdate=0
     echo ""
     if [ "${#ClientID}" -eq 0 ]; then
       echo "Your ClientID is not set"
       NeedUpdate=1
     else
       echo "Your ClientID is set to: $ClientID."
       echo "Is this information correct?"
       echo ""
       parse_user_input 1 1 0
       USER_RESPONSE=$?
       if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
         NeedUpdate=1
       fi
     fi
     if [ $NeedUpdate -eq 1 ]; then
       echo ""
       echo "Please enter your ClientID."
       echo "This value should match the information at https://developer.amazon.com/edw/home.html."
       echo "The information is located under the 'Security Profile' tab."
       echo "E.g.: amzn1.application-oa2-client.xxxxxxxx"
       get_credential 28
       ClientID=$Credential
     fi

     echo "-------------------------------"
     echo "ClientID is set to >> $ClientID"
     echo "-------------------------------"

     # Check ClientSecret
     NeedUpdate=0
     echo ""
     if [ "${#ClientSecret}" -eq 0 ]; then
       echo "Your ClientSecret is not set"
       NeedUpdate=1
     else
       echo "Your ClientSecret is set to: $ClientSecret."
       echo "Is this information correct?"
       echo ""
       parse_user_input 1 1 0
       USER_RESPONSE=$?
       if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
         NeedUpdate=1
       fi
     fi
     if [ $NeedUpdate -eq 1 ]; then
       echo ""
       echo "Please enter your ClientSecret."
       echo "This value should match the information at https://developer.amazon.com/edw/home.html."
       echo "The information is located under the 'Security Profile' tab."
       echo "E.g.: fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa"
       get_credential 20
       ClientSecret=$Credential
     fi

     echo "-------------------------------"
     echo "ClientSecret is set to >> $ClientSecret"
     echo "-------------------------------"

     check_credentials
   }
   if [ "$ProductID" = "YOUR_PRODUCT_ID_HERE" ]; then
     ProductID=""
   fi
   if [ "$ClientID" = "YOUR_CLIENT_ID_HERE" ]; then
     ClientID=""
   fi
   if [ "$ClientSecret" = "YOUR_CLIENT_SECRET_HERE" ]; then
     ClientSecret=""
   fi

   check_credentials
   # Preconfigured variables
   OS=rpi
   User=$(id -un)
   Group=$(id -gn)
   Origin=/home/pi/alexa-avs-sample-app
   Samples_Loc=$Origin/samples
   Java_Client_Loc=$Samples_Loc/javaclient
   Wake_Word_Agent_Loc=$Samples_Loc/wakeWordAgent
   Companion_Service_Loc=$Samples_Loc/companionService
   Kitt_Ai_Loc=$Wake_Word_Agent_Loc/kitt_ai
   Sensory_Loc=$Wake_Word_Agent_Loc/sensory
   External_Loc=$Wake_Word_Agent_Loc/ext
   Locale="en-US"

   mkdir $Kitt_Ai_Loc
   mkdir $Sensory_Loc
   mkdir $External_Loc


   # Select a Locale
   clear
   echo "==== Setting Locale ====="
   echo ""
   echo ""
   echo "Which locale would you like to use?"
   echo ""
   echo ""
   echo "======================================================="
   echo ""
   echo ""
   select_option Locale "en-US" "en-GB" "de-DE"

   Wake_Word_Detection_Enabled="true"

   echo ""
   echo ""
   echo "==============================================="
   echo " Making sure we are installing to the right OS"
   echo "==============================================="
   echo ""
   echo ""
   echo "=========== Installing Oracle Java8 ==========="
   echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
   chmod +x $Java_Client_Loc/install-java8.sh
   cd $Java_Client_Loc && bash ./install-java8.sh
   cd $Origin

   echo ""
   echo ""
   echo "==============================="
   echo "*******************************"
   echo " *** STARTING Alexa Installation ***"
   echo "  ** Grab a Coffee or Beer and relax this will take quite a while**"
   echo "   *************************"
   echo "   ========================="
   echo ""
   echo ""

   # Install dependencies

   echo "========== Getting the code for Kitt-Ai ==========="
   cd $Kitt_Ai_Loc
   git clone https://github.com/Kitt-AI/snowboy.git

   echo "========== Getting the code for Sensory ==========="
   cd $Sensory_Loc
   git clone https://github.com/Sensory/alexa-rpi.git

   cd $Origin

   echo "========== Installing Libraries for Kitt-Ai and Sensory: ALSA, Atlas ==========="
   sudo apt-get -y install libasound2-dev
   sudo apt-get -y install libatlas-base-dev
   sudo ldconfig

   echo "========== Installing WiringPi ==========="
   sudo apt-get -y install wiringpi
   sudo ldconfig

   echo "========== Installing VLC and associated Environmental Variables =========="
   sudo apt-get install -y vlc vlc-nox vlc-data
   #Make sure that the libraries can be found
   sudo sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
   sudo sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"

   # Create a libvlc soft link if doesn't exist
   if ! ldconfig -p | grep "libvlc.so "; then
     [ -e $Java_Client_Loc/lib ] || mkdir $Java_Client_Loc/lib
     if ! [ -e $Java_Client_Loc/lib/libvlc.so ]; then
      Target_Lib=`ldconfig -p | grep libvlc.so | sort | tail -n 1 | rev | cut -d " " -f 1 | rev`
      ln -s $Target_Lib $Java_Client_Loc/lib/libvlc.so
     fi
   fi

   sudo ldconfig

   echo "========== Installing NodeJS =========="
   sudo apt-get install -y nodejs npm build-essential
   sudo ln -s /usr/bin/nodejs /usr/bin/node
   node -v
   sudo ldconfig

   echo "========== Installing Maven =========="
   sudo apt-get install -y maven
   mvn -version
   sudo ldconfig

   echo "========== Installing OpenSSL and Generating Self-Signed Certificates =========="
   sudo apt-get install -y openssl
   sudo ldconfig

   echo "========== Downloading and Building Port Audio Library needed for Kitt-Ai Snowboy =========="
   cd $Kitt_Ai_Loc/snowboy/examples/C++
   bash ./install_portaudio.sh
   sudo ldconfig
   cd $Kitt_Ai_Loc/snowboy/examples/C++
   make -j4
   sudo ldconfig
   cd $Origin

   echo "========== Generating ssl.cnf =========="
   if [ -f $Java_Client_Loc/ssl.cnf ]; then
     rm $Java_Client_Loc/ssl.cnf
   fi
   use_template $Java_Client_Loc template_ssl_cnf ssl.cnf

   echo "========== Generating generate.sh =========="
   if [ -f $Java_Client_Loc/generate.sh ]; then
     rm $Java_Client_Loc/generate.sh
   fi
   use_template $Java_Client_Loc template_generate_sh generate.sh

   echo "========== Executing generate.sh =========="
   chmod +x $Java_Client_Loc/generate.sh
   cd $Java_Client_Loc && bash ./generate.sh
   cd $Origin

   echo "========== Configuring Companion Service =========="
   if [ -f $Companion_Service_Loc/config.js ]; then
     rm $Companion_Service_Loc/config.js
   fi
   use_template $Companion_Service_Loc template_config_js config.js

   echo "========== Configuring Java Client =========="
   if [ -f $Java_Client_Loc/config.json ]; then
     rm $Java_Client_Loc/config.json
   fi
   use_template $Java_Client_Loc template_config_json config.json

   echo "========== Configuring ALSA Devices =========="
   if [ -f /home/$User/.asoundrc ]; then
     rm /home/$User/.asoundrc
   fi
   printf "pcm.!default {\n  type asym\n   playback.pcm {\n     type plug\n     slave.pcm \"hw:0,0\"\n   }\n   capture.pcm {\n     type plug\n     slave.pcm \"hw:1,0\"\n   }\n}" >> /home/$User/.asoundrc

   echo "========== Installing CMake =========="
   sudo apt-get install -y cmake
   sudo ldconfig

   echo "========== Installing Java Client =========="
   if [ -f $Java_Client_Loc/pom.xml ]; then
     rm $Java_Client_Loc/pom.xml
   fi

   get_alpn_version

   cp $Java_Client_Loc/pom_pi.xml $Java_Client_Loc/pom.xml

   sed -i "s/The latest version of alpn-boot that supports .*/The latest version of alpn-boot that supports JDK $Java_Version -->/" $Java_Client_Loc/pom.xml
   sed -i "s:<alpn-boot.version>.*</alpn-boot.version>:<alpn-boot.version>$Alpn_Version</alpn-boot.version>:" $Java_Client_Loc/pom.xml

   cd $Java_Client_Loc && mvn validate && mvn install && cd $Origin

   echo "========== Installing Companion Service =========="
   cd $Companion_Service_Loc && npm install && cd $Origin

   if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
     echo "========== Preparing External dependencies for Wake Word Agent =========="
     mkdir $External_Loc/include
     mkdir $External_Loc/lib
     mkdir $External_Loc/resources

     cp $Kitt_Ai_Loc/snowboy/include/snowboy-detect.h $External_Loc/include/snowboy-detect.h
     cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/portaudio.h $External_Loc/include/portaudio.h
     cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_ringbuffer.h $External_Loc/include/pa_ringbuffer.h
     cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_util.h $External_Loc/include/pa_util.h
     cp $Kitt_Ai_Loc/snowboy/lib/$OS/libsnowboy-detect.a $External_Loc/lib/libsnowboy-detect.a
     cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/lib/libportaudio.a $External_Loc/lib/libportaudio.a
     cp $Kitt_Ai_Loc/snowboy/resources/common.res $External_Loc/resources/common.res
     cp $Kitt_Ai_Loc/snowboy/resources/alexa/alexa-avs-sample-app/alexa.umdl $External_Loc/resources/alexa.umdl

     sudo ln -s /usr/lib/atlas-base/atlas/libblas.so.3 $External_Loc/lib/libblas.so.3

     $Sensory_Loc/alexa-rpi/bin/sdk-license file $Sensory_Loc/alexa-rpi/config/license-key.txt $Sensory_Loc/alexa-rpi/lib/libsnsr.a $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-20500.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-21000.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr
     cp $Sensory_Loc/alexa-rpi/include/snsr.h $External_Loc/include/snsr.h
     cp $Sensory_Loc/alexa-rpi/lib/libsnsr.a $External_Loc/lib/libsnsr.a
     cp $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr $External_Loc/resources/spot-alexa-rpi.snsr

     mkdir $Wake_Word_Agent_Loc/tst/ext
     cp -R $External_Loc/* $Wake_Word_Agent_Loc/tst/ext
     cd $Origin

     echo "========== Compiling Wake Word Agent =========="
     cd $Wake_Word_Agent_Loc/src && cmake . && make -j4
     cd $Wake_Word_Agent_Loc/tst && cmake . && make -j4
   fi

   chown -R $User:$Group $Origin
   chown -R $User:$Group /home/$User/.asoundrc

   cd $Origin
   cd /home/pi/
   echo ""
   echo '============================='
   echo '*****************************'
   echo '========= Finished Installing Alexa =========='
   echo '*****************************'
   echo '============================='
   echo ""

elif [ "$assistants" = "Both" ] || [ "$assistants" = "Google-Assistant" ] ; then
   echo "Have you downloaded the credentials file, renamed it to assistant.json and placed it in /home/pi/ directory?"
   parse_user_input 1 1 0
   USER_RESPONSE=$?
   if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
     echo "=============Starting Google Assistant Installer============="
     git clone https://github/shivasiddharth/GassistPi -b Gassistant-RPi
     sudo chmod +x /home/pi/Assistants-Pi/scripts/snowboy-deps-installer.sh
     sudo chmod +x /home/pi/Assistants-Pi/scripts/gassist-installer-pi3.sh
     sudo /home/pi/Assistants-Pi/scripts/snowboy-deps-installer.sh
     sudo /home/pi/Assistants-Pi/scripts/gassist-installer-pi3.sh
     echo ""
     echo "Finished installing Google Assistant....."
   elif ["$USER_RESPONSE" = "$NO_ANSWER" ]; then
     echo "Download the credentials file, rename it to assistant.json, place it in /home/pi/ directory and start the installer again.."
     exit
   fi
else
  echo "Quitting the installer........... See ya...."
  exit
fi
clear
case $assistants in
  Alexa)
    sudo chmod +x /home/pi/Assistants-Pi/scripts/clientstart.sh
    sudo chmod +x /home/pi/Assistants-Pi/scripts/companionstart.sh
    sudo chmod +x /home/pi/Assistants-Pi/scripts/service-installer.sh
    sudo chmod +x /home/pi/Assistants-Pi/scripts/wakeword.sh
    sudo /home/pi/Assistants-Pi/scripts/service-installer.sh
    sudo systemctl enable companionapp.service
    sudo systemctl enable client.service
    sudo systemctl enable wakeword.service
    clear
    echo "Enabled Alexa service to start on boot"
    echo ""
    echo "Run the Alexa demo once to authenticate"
    echo ""
    Number_Terminals=2
    if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
      Number_Terminals=3
    fi
    echo "To run the demo, do the following in $Number_Terminals seperate terminals:"
    echo "Run the companion service: cd $Companion_Service_Loc && sudo npm start"
    echo "Run the AVS Java Client: cd $Java_Client_Loc && sudo mvn exec:exec"
    if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
      echo "Run the wake word agent: "
      echo "  KITT_AI: cd $Wake_Word_Agent_Loc/src && sudo ./wakeWordAgent -e kitt_ai"
    fi
    echo "After verifying the working of Alexa, restart the Pi to start the services"
    exit
    ;;
  Google-Assistant)
    sudo chmod +x /home/pi/Assistants-Pi/scripts/service-installer.sh
    sudo /home/pi/Assistants-Pi/scripts/service-installer.sh
    sudo systemctl enable gassistpi-ok-google.service
    clear
    echo "Enabled Google Assistant service to start on boot"
    echo "Do you want to enable custom wakeword service for Google Assistant?"
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      echo "======Enabling custom wakeword======="
      sudo systemctl enable snowboy.service
    fi
    echo ""
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      echo "Later if you have  achange of mind, you can enable custom wakeword service by typing the following in a terminal:"
      echo "sudo systemctl enable snowboy.service"
    fi
    echo "Try running the google assistant demo"
    echo "Open a new terminal and execute: "
    echo "source env/bin/activate"
    echo "google-assistant-demo"
    echo "After verifying the working of google-assistant-demo, restart the Pi to start the services"
    exit
    ;;
  Both)
    Number_Terminals=2
    if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
      Number_Terminals=3
    fi
    sudo chmod +x /home/pi/Assistants-Pi/scripts/clientstart.sh
    sudo chmod +x /home/pi/Assistants-Pi/scripts/companionstart.sh
    sudo chmod +x /home/pi/Assistants-Pi/scripts/service-installer.sh
    sudo chmod +x /home/pi/Assistants-Pi/scripts/wakeword.sh
    sudo /home/pi/Assistants-Pi/scripts/service-installer.sh
    sudo systemctl enable companionapp.service
    sudo systemctl enable client.service
    sudo systemctl enable wakeword.service
    sudo systemctl enable gassistpi-ok-google.service
    clear
    echo "Do you want to enable custom wakeword service for Google Assistant?"
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      echo "======Enabling custom wakeword======="
      sudo systemctl enable snowboy.service
      clear
    fi
    echo ""
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      echo "Later if you have  achange of mind, you can enable custom wakeword service by typing the following in a terminal:"
      echo "sudo systemctl enable snowboy.service"
    fi
    echo "Enabled Alexa and Google Assistant services to start on boot"
    echo ""
    echo "================Run the Alexa demo to authenticate============"
    echo "To run the demo, do the following in $Number_Terminals seperate terminals:"
    echo "Run the companion service: cd $Companion_Service_Loc && sudo npm start"
    echo "Run the AVS Java Client: cd $Java_Client_Loc && sudo mvn exec:exec"
    if [ "$Wake_Word_Detection_Enabled" = "true" ]; then
      echo "Run the wake word agent: "
      echo "  KITT_AI: cd $Wake_Word_Agent_Loc/src && sudo ./wakeWordAgent -e kitt_ai"
    fi
    echo ""
    echo ""
    echo "===============Run Google Assistant demo==========="
    echo "To run the google assistant demo"
    echo "Open a new terminal and execute: "
    echo "source env/bin/activate"
    echo "google-assistant-demo"
    echo ""
    echo "After verifying the working of both, restart the Pi to start the services"
    exit
esac
