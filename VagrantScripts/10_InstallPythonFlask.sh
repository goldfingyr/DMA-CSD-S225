#!/bin/bash
# CAVEAT: We are root @ /home/vagrant
# Installing Python Flask
# https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world
TARGET="Python FLASK"
echo "*** Installing $TARGET..."
echo "User: $UID @ $PWD"
apt-get -y install python3-pip python3-venv virtualenv python-wheel-common
echo "*** Installing $TARGET...DONE"


cat << EOF
# Notes about running flask
mkdir xxx
cd xxx
# create virtual environment
python3 -m venv venv
# activate virtual environment
virtualenv venv
# Transfer into virtual environment
. venv/bin/activate
# to exit use command deactivate
pip install flask pika requests datetime

#
#
# To run the app
export FLASK_APP=xxx.py
flask run
EOF
