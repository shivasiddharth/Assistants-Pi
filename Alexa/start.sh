#!/bin/bash

LOG_FOLDER="/home/pi/Assistants-Pi/Alexa/log"
ALEXA_FOLDER="/home/pi/Assistants-Pi/Alexa"

_psName2Ids(){
    ps -aux | grep -i "$1" | awk '{print $2}'
}

psKill(){
     _psName2Ids $1 | xargs sudo kill -9 > /dev/null 2>&1;
}

findError(){
    cat ${LOG_FOLDER}/$(ls ${LOG_FOLDER} | tail -1)  | grep "$1" | wc | awk '{print $1}'
}

# check errors
error1=$(findError "AbstractKeywordDetector")
error2=$(findError "RequiresShutdown")
error3=$(findError "Alexa is currently idle!")

processes=($(_psName2Ids "alexa.py"))
if [ ${#processes[@]} -le 1 ] || [ $error1 -gt 10 ] || [ $error2 -gt 0 ] || [ $error3 -lt 2 ] ; then

    now=$(date -u +"%d-%m-%Y")
    sudo touch "$LOG_FOLDER/$now.log"
    sudo chmod go+rwx "$LOG_FOLDER/$now.log"
    cd "$ALEXA_FOLDER"
    psKill "alexa.py"

    screen -L "$LOG_FOLDER/$now.log" -dm sudo python alexa.py
fi;
