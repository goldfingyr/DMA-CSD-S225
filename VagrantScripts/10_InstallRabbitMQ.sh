#!/bin/bash
# CAVEAT: We are root @ /home/vagrant
# Installing RabbitMQ
TARGET="RabbitMQ"
echo "*** Installing $TARGET..."
echo "User: $UID @ $PWD"
apt-get -y install rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
rabbitmqctl add_user vagrant vagrant
rabbitmqctl set_user_tags vagrant administrator
echo "*** Installing $TARGET...DONE"


cat << EOF
RabbitMQ admin interface available at http://{node-hostname}:15672/
EOF
