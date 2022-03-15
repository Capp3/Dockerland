#!/bin/sh
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | sudo python3
git clone https://github.com/anudeepND/whitelist.git
sudo python3 whitelist/scripts/whitelist.py
git clone https://github.com/anudeepND/whitelist.git
sudo ./whitelist/scripts/referral.sh
pihole -g