# get zerotier member id and serve over flask.

from flask import Flask
import subprocess
from time import sleep

LINE_CLEAR = '\x1b[2K'
print('\033[?25l', end='', flush=True)  # Hide cursor

def loading():
    for dot in ['.', '..', '...']:
        print(f'Loading{dot}   ', end='\r')
        sleep(0.5)

spin_a = ['-', '\\', '|', '/']
spin_b = ['⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷']
spin_c = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
arc = ["◜", "◠", "◝", "◞", "◡", "◟"]

def spinner(spin_list, spin_delay):
    for spin in spin_list:
        print(spin + " loading...", end='\r')
        sleep(spin_delay)

while True:
    # parse command output
    command_output = subprocess.check_output([
        "zerotier-cli", "listnetworks"
    ]).decode("utf-8")
    output_lines = command_output.splitlines()

    # wait for zerotier connection
    num_connections = len(output_lines)-1
    spinner(spin_c, 0.04)
    if num_connections >= 1:
        print("number of connections:", num_connections)
        break


# Find the line that contains 'zt'
command_output = subprocess.check_output([
    "ip", "a"
]).decode("utf-8")
output_lines = command_output.splitlines()
start_index = None
for i, line in enumerate(output_lines):
    if ' zt' in line:
        start_index = i
        break
for j in range(0,4):
    print(output_lines[i+j])

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World! {}</p>".format(output_lines[i])