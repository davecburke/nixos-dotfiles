#!/usr/bin/env python3
import subprocess
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-l', '--label', default='INBOX')
parser.add_argument('-p', '--prefix', default='\uf0e0')
parser.add_argument('-c', '--color', default='#e06c75')
parser.add_argument('-ns', '--nosound', action='store_true')
args = parser.parse_args()

unread_prefix = '%{F' + args.color + '}' + args.prefix + ' %{F-}'

res = subprocess.Popen("~/.config/polybar/scripts/dunst-notify/dunst-notify.sh", stdout=subprocess.PIPE, shell=True)
(output, err) = res.communicate()
p_status = res.wait()

val = output
val = val.decode('utf-8')
l = val.split('\n',2)[0] 
notRead = ''
if int(l) > 0:
    notRead = unread_prefix + str(l)
    if not args.nosound and int(l) > 0:
        subprocess.run(['canberra-gtk-play', '-i', 'message'])
else:
    notRead = args.prefix + ' ' + str(l)
print(notRead, flush=True)
if int(p_status) > 0:
    exit(33)     
