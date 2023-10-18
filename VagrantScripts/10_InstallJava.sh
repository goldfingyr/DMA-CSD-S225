#!/bin/bash

if [ $UID -eq 0 ]; then
  apt-get -y install default-jdk
  apt-get -y install default-jre
else
  sudo apt-get -y install default-jdk
  sudo apt-get -y install default-jre
fi
