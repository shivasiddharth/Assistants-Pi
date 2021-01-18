#!/bin/bash

ALEXA_FOLDER="/home/pi/Assistants-Pi/Alexa"

_psName2Ids(){
    ps -aux | grep -i "$1" | awk '{print $2}'
}

psKill(){
     _psName2Ids $1 | xargs sudo kill -9 > /dev/null 2>&1;
}

processes=($(_psName2Ids "alexa.py"))
if [ ${#processes[@]} -le 1 ]; then
    cd "$ALEXA_FOLDER"
    pkill "alexa.py"
    sudo screen -dm sudo python3 /home/pi/Assistants-Pi/Alexa/alexa.py
fi;
