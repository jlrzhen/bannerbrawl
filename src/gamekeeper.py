"""Get zerotier member id and serve over flask."""

import subprocess
import random
from flask import Flask, jsonify, render_template, request, redirect, url_for

# gunicorn --bind 0.0.0.0:5000 gamekeeper:app --daemon
app = Flask(__name__)

players = []
flags = []
winner = None
message_str = "none"
room_id = None

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
    """new player registers their username"""
    global room_id
    if room_id is None:
        room_id = random.randint(0,999)
    if username not in players:
        players.append(username)
    res = redirect(url_for('dashboard'))   
    res.set_cookie('room_id', str(room_id))  
    res.set_cookie('username', username)
    return res

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
    """set flag"""
    flags.append(flag)
    return redirect(url_for('dashboard'))

#todo: redirect all players to winner page and have all confirm new game (like ready button)

@app.route("/submit/<flag>")
def submit_flag(flag):
    """submit flag"""
    global message_str, winner
    if winner is not None and flag in flags:
        winner = request.cookies.get('username')
        message_str = f"winner! {winner} submitted flag: {flag}"
    return redirect(url_for('dashboard')) #todo: redirect to winner page

@app.route("/quit")
def quit():
    """quit game"""
    username = request.cookies.get('username')
    if username in players:
        players.remove(username)
    res = redirect(url_for('dashboard'))  
    res.delete_cookie('username')
    res.delete_cookie('room_id')
    return res

if __name__ == "__main__":
    app.run()
