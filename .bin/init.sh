#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install -y python3-pip
python3 -m pip install --user ansible --break-system-packages
export PATH="$HOME/.local/bin:$PATH"

read -p "When finished, press enter." -n 1 -r
ansible-playbook main.yml --ask-become-pass
