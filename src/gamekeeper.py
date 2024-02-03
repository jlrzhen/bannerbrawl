"""Get zerotier member id and serve over flask."""

import subprocess
from flask import Flask, jsonify, render_template, request, redirect, url_for, Response

# gunicorn --bind 0.0.0.0:5000 ./kingtower:app --daemon
app = Flask(__name__)

players = []
flags = []
winner = None
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

@app.route("/debug")
def debug():
    return f"players: {players} flags: {flags} winner: {winner}"

@app.route("/username/<username>")
def submit_username(username):
    """submit username"""
    players.append(username)
    return redirect(url_for('dashboard'))

@app.route("/dashboard")
def dashboard():
    """show dashboard"""
    if request.cookies.get('username') is None:
        return render_template('joinpage.html')
    return render_template(
        'dashboard.html', message=message_str, username=request.cookies.get('username')
    )

@app.route("/setflag/<flag>")
def setflag(flag):
    flags.append(flag)
    return redirect(url_for('dashboard'))

#todo: redirect all players to winner page and have all confirm new game (like ready button)
#Response.delete_cookie('username')


@app.route("/submit/<flag>")
def submit_flag(flag):
    global message_str, winner
    for f in flags:
        if f == flag:
            winner = request.cookies.get('username')
            message_str = f"winner! {winner} submitted flag: {f}"
    return redirect(url_for('dashboard')) #todo: redirect to winner page

if __name__ == "__main__":
    app.run()
