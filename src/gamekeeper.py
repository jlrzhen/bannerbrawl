"""Get zerotier member id and serve over flask."""

import subprocess
import random
from flask import Flask, jsonify, render_template, request, redirect, url_for

# gunicorn --bind 0.0.0.0:5000 gamekeeper:app --daemon
app = Flask(__name__)

players = []
flags = []
winner = None
messages_str = [""] * 10
room_id = None
reset_pending = True

def log_msg(msg):
    global messages_str
    messages_str.append(f"[LOG] {msg}")
    messages_str.pop(0)

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
    return f"players: {players} flags: {flags} winner: {winner} messages_str: {messages_str}"

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
    log_msg(f"{username} has joined the room.")
    global reset_pending
    if reset_pending is True:
        reset_pending = False
    return res

@app.route("/dashboard")
def dashboard():
    """show dashboard"""
    username = request.cookies.get('username') 
    if username is None or username not in players:
        return render_template('joinpage.html')
    return render_template(
        'dashboard.html', messages_str=messages_str, username=request.cookies.get('username')
    )

@app.route("/setflag/<flag>")
def setflag(flag):
    """set flag"""
    username = request.cookies.get('username') 
    flags.append({username: flag})
    return redirect(url_for('dashboard'))

#todo: redirect all players to winner page and have all confirm new game (like ready button)

@app.route("/submit/<flag>")
def submit_flag(flag):
    """submit flag"""
    global winner
    username = request.cookies.get('username')
    if winner is None:
        if any(flag in d.values() for d in flags if username not in d.keys()):
            winner = request.cookies.get('username')
            log_msg(f"WINNER! {winner} submitted flag: {flag}")
        else:
            log_msg(f"INCORRECT FLAG submitted by {username}: {flag}")
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
    global reset_pending
    if reset_pending is False:
        log_msg(f"{username} has left the room.")
    else:
        reset_pending = False
    return res

@app.route("/reset")
def reset_game():
    global players
    players = []
    global flags
    flags = []
    global winner
    winner = None
    global messages_str
    messages_str = [""] * 10
    global room_id
    room_id = None
    global reset_pending
    reset_pending = True
    return redirect(url_for('quit'))

if __name__ == "__main__":
    app.run()
