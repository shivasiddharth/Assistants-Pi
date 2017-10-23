#!/bin/bash
cd /home/pi/alexa-avs-sample-app/samples
sleep 45
aplay /home/pi/Assistants-Pi/Startup.wav
cd wakeWordAgent/src && sudo ./wakeWordAgent -e kitt_ai
