"""useful functions"""

from time import sleep

LINE_CLEAR = '\x1b[2K'
print('\033[?25l', end='', flush=True)  # Hide cursor

def loading():
    """loading dots"""
    for dot in ['.', '..', '...']:
        print(f'Loading{dot}   ', end='\r')
        sleep(0.5)

spin_a = ['-', '\\', '|', '/']
spin_b = ['⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷']
spin_c = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
arc = ["◜", "◠", "◝", "◞", "◡", "◟"]

def spinner(spin_list, spin_delay):
    """spinner animation"""
    for spin in spin_list:
        print(spin + " loading...", end='\r')
        sleep(spin_delay)
