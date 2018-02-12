# Assistants-Pi
## One installer for both Google Asistant and Amazon Alexa   
## Simultaneously run Google Assistant and Alexa on Raspberry Pi    
*******************************************************************************************************************************
### **If you like the work, find it useful and if you would like to get me a :coffee: :smile:** [![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7GH3YDCHZ36QN)  

*******************************************************************************************************************************
### Note:  
**Due to the 20th Dec update to Google Assistant SDK, the installation process has remarkably changed. Please Read through this document carefully**  
**Refer to this video https://youtu.be/vprJBDDYE8Q for critical steps in Google Assistant installation** 

**The Google Assistant Component used in this project is the GassistPi project. So for 'Preliminary Setups for the customizations and respective How-Tos' check this [out](https://github.com/shivasiddharth/GassistPi/blob/master/README.md#using-the-customizations)**  
****************************************************************
**Before Starting the setup**
****************************************************************
**For Google Assistant**  
1. Download credentials--->.json file (refer to this doc for creating credentials https://developers.google.com/assistant/sdk/develop/python/config-dev-project-and-account)   

2. Place the .json file in/home/pi directory  

3. **DO NOT RENAME THE JSON FILE**

**For Amazon Alexa**  
1. Create a security profile for alexa-avs-sample-app if you already don't have one.  
https://github.com/alexa/alexa-avs-sample-app/wiki/Create-Security-Profile

***************************************************************
**Setup Amazon Alexa, Google Assistant or Both**     
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
5. Make sure that contents of asoundrc match the contents of asound.conf    
   Open a terminal and type:  
```
sudo nano /etc/asound.conf
```
Open a second terminal and type:    
```
sudo nano ~/.asoundrc
```
If the contents of .asoundrc are not same as asound.conf, copy the contents from asound.conf to .asoundrc, save using ctrl+x and y

6. Test the audio setup using:  
```
sudo /home/pi/Assistants-Pi/audio-test.sh  
```
7. Restart the Pi using:
```
sudo reboot
```
8. Install the assistant/assistants using the following. This is an interactive script, so just follow the onscreen instructions:
```
sudo /home/pi/Assistants-Pi/installer.sh  
```
9. After verification of the assistants, to make them auto start on boot:  
Pi 3 and Pi2 users, open the gassistpi-ok-google.service in the /home/pi/Assistants-Pi/systemd folder and add your project-id and model-id in the indicated points.    
Pi Zero users, open the gassistpi-push-button.service in the /home/pi/Assistants-Pi/systemd folder and add your project-id and model-id in the indicated points.  
After that, open a terminal and run the following commands:  
```
sudo chmod +x /home/pi/Assistants-Pi/scripts/service-installer.sh
sudo chmod +x /home/pi/Assistants-Pi/scripts/clientstart.sh  
sudo chmod +x /home/pi/Assistants-Pi/scripts/companionstart.sh  
sudo chmod +x /home/pi/Assistants-Pi/scripts/wakeword.sh  
sudo /home/pi/Assistants-Pi/scripts/service-installer.sh  
sudo systemctl enable companionapp.service
sudo systemctl enable client.service
sudo systemctl enable wakeword.service
sudo systemctl enable stopbutton.service
```
#If using Pi 2B or Pi 3B  
```
sudo systemctl enable gassistpi-ok-google.service  
```
#If using Pi zero  
```
sudo systemctl enable gassistpi-push-button.service  
```
### MANUALLY START THE ASSISTANT

At any point of time, if you wish to manually start the assistant:

**Ok-Google Hotword/Pi3/Pi2/Armv7 users**   
Open a terminal and execute the following:
```
/home/pi/env/bin/python -u /home/pi/GassistPi/src/main.py --project_id 'replace this with your project id'  --device_model_id 'replace this with the model id'

```
**Pushbutton/Pi Zero/Pi B+ and other users**   
Open a terminal and execute the following:
```
/home/pi/env/bin/python -u /home/pi/GassistPi/src/pushbutton.py --project-id 'replace this with your project id'  --device-model-id 'replace this with the model id'
