# Assistants-Pi---Untested not ready for public yet
**One installer for both Google Asistant and Amazon Alexa**  
**Simultaneously run Google Assistant and Alexa on Raspberry Pi**  

****************************************************************
**Before Starting the setup**
****************************************************************
**For Google Assistant**  
1. Download credentials--->.json file (refer to this doc for creating credentials https://developers.google.com/assistant/sdk/develop/python/config-dev-project-and-account)   

2. Place the .json file in/home/pi directory  

3. Rename it to assistant--->assistant.json 

**For Amazon Alexa**  
1. Create a security profile for alexa-avs-sample-app if you already don't have one.  
https://github.com/alexa/alexa-avs-sample-app/wiki/Create-Security-Profile

***************************************************************
**Setup Amazon Alexa, Google Assistant or Both **
***************************************************************
1. Clone the git using:
```
git clone https://github.com/shivasiddharth/Assistants-Pi  
```
2. Make the installers executable using:
```
sudo chmod +x /home/pi/Assistants-Pi/prep-system.sh    
sudo chmod +x /home/pi/Assistants-Pi/audio-test.sh   
sudo chmod +x /home/pi/Assistants-Pi/installer.sh  
```
3. Prepare the system for installing assistants by updating, upgrading and setting up audio using:  
```
sudo /home/pi/Assistants-Pi/prep-system.sh
```
4. Restart the Pi using:
```
sudo reboot
```
5. Test the aduio setup using:  
```
sudo /home/pi/Assistants-Pi/audio-test.sh  
```
6. Install the assistant/assistants using the following. This is an interactive script, so just follow the onscreen instructions: 
```
sudo /home/pi/Assistants-Pi/installer.sh  
```
