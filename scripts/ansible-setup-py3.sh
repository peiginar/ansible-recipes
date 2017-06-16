#!/bin/bash
set -xe
venvdir=${1:-${HOME}/venv/ansible}
sudo apt update -qq
sudo apt install -y python3-venv python3-dev libffi-dev libssl-dev gcc

(
python3 -m venv $venvdir
set +x; . $venvdir/bin/activate; set -x;

proxy="${http_proxy:-http://xproxy:13128/}"
pip install --proxy=$proxy --upgrade pip
pip install --proxy=$proxy ansible pywinrm
ansible --version
)
echo "done..."
