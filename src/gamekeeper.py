"""Get zerotier member id and serve over flask."""

import subprocess
from flask import Flask, jsonify, render_template

# gunicorn --bind 0.0.0.0:5000 ./kingtower:app --daemon
app = Flask(__name__)

flags = []
message_str = "none"

@app.route("/")
def hello_world():
    """return network and member id"""
    network_id = ''
    member_id = ''

    # parse command output
    command_output = subprocess.check_output([
        "zerotier-cli", "listnetworks"
    ]).decode("utf-8")
    output_lines = command_output.splitlines()

    # get zerotier connection
    num_connections = len(output_lines)-1
    if num_connections >= 1:
        network_id = output_lines[1].split()[2]
        member_id = subprocess.check_output([
            "zerotier-cli", "info"
        ]).decode("utf-8").split()[2]

    return jsonify({
        "network_id": network_id,
        "member_id": member_id
    })

@app.route("/dashboard")
def dashboard():
    """show dashboard"""
    return render_template('dashboard.html', message=message_str)

@app.route("/setflag/<flag>")
def setflag(flag):
    flags.append(flag)
    return render_template('dashboard.html', message=message_str)

@app.route("/submit/<flag>")
def submit_flag(flag):
    for f in flags:
        if f == flag:
            message_str = f"winner submitted flag: {f}"
            return render_template('dashboard.html', message=message_str)
    return render_template('dashboard.html', message=message_str)

@app.route("/debug")
def debug():
    return f"flags: {flags}"

if __name__ == "__main__":
    app.run()
