#!/bin/bash
# CAVEAT: We are root @ /home/vagrant
# Installing RabbitMQ
TARGET="NFS Client"
echo "*** Installing $TARGET..."
echo "User: $UID @ $PWD"
apt-get -y install nfs-common
echo "*** Installing $TARGET...DONE"
