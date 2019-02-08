import subprocess
import os
import tempfile
import shlex
import time

#Comment the line below if you want to create your own indicator pattern
from alexaindicator import assistantindicator


ROOT_PATH = os.path.realpath(os.path.join(__file__, '..', '..'))
USER_PATH = os.path.realpath(os.path.join(__file__, '..', '..','..'))


def run_command(command):
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE)
    while True:
        time.sleep(.1)
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            print(output.strip())
            if "authorized" in str(output.strip()).lower():
                #Change the path to your desired audio file for the startup tone
                subprocess.Popen(["aplay", "{}/Assistants-Pi/sample-audio-files/AlexaStartup.wav".format(USER_PATH)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                #Comment the line below if you want to create your own indicator pattern
                assistantindicator('off')
            if "listening..." in str(output.strip().lower()):
                #Change the path to your desired audio file for the trigger alert tone
                subprocess.Popen(["aplay", "{}/Assistants-Pi/sample-audio-files/AlexaTriggered.wav".format(USER_PATH)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                #Comment the line below if you want to create your own indicator pattern
                assistantindicator('listening')
            if "speaking..." in str(output.strip()).lower():
                #Comment the line below if you want to create your own indicator pattern
                assistantindicator('speaking')
            if "idle!" in str(output.strip().lower()) or "SPEAKING,to=IDLE" in str(output.strip()):
                #Comment the line below if you want to create your own indicator pattern
                assistantindicator('off')
    rc = process.poll()
    return rc

#Change the path to your startsample file
run_command("sudo {}/Assistants-Pi/Alexa/startsample.sh".format(USER_PATH))
