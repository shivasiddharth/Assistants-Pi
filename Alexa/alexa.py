import subprocess
import os
import tempfile
import shlex
from alexaindicator import assistantindicator


ROOT_PATH = os.path.realpath(os.path.join(__file__, '..', '..'))
USER_PATH = os.path.realpath(os.path.join(__file__, '..', '..','..'))


def run_command(command):
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE)
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            print(output.strip())
            if "authorized" in str(output.strip()).lower():
                subprocess.Popen(["aplay", "{}/Assistants-Pi/sample-audio-files/Startup.wav".format(USER_PATH)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                assistantindicator('off')
            if "AudioInputProcessor:setState:from=IDLE,to=RECOGNIZING" in str(output.strip()):
                subprocess.Popen(["aplay", "{}/Assistants-Pi/sample-audio-files/Fb.wav".format(USER_PATH)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                assistantindicator('listening')
            if "speaking..." in str(output.strip()).lower():
                assistantindicator('speaking')
            if "idle!" in str(output.strip().lower()) or "SPEAKING,to=IDLE" in str(output.strip()):
                assistantindicator('off')
    rc = process.poll()
    return rc

run_command("sudo {}/Assistants-Pi/Alexa/startsample.sh".format(USER_PATH))
