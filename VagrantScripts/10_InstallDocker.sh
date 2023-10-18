#!/bin/bash
# CAVEAT: We are root @ /home/vagrant
# Installing Docker
#
# CAVEAT: Installing sequence: Docker/Apache
# If Apache is installed subsequently to Docker then Apache will have access to Docker
# See the Apache install script
echo "*** 10_InstallDocker.sh ..."
[ -z $1 ] && dcFile="docker-compose.yml" || dcFile="$1"
echo "Docker compose file: $dcFile"
echo "User: $UID @ $PWD"
for nn in ntp apt-transport-https ca-certificates curl software-properties-common; do
  if [ $UID -eq 0 ]; then
    apt-get -y install $nn
  else
    sudo apt-get -y install $nn
  fi
done
thisArch=$(uname -m)
myArch="UNKNOWN"
[ "$thisArch" == "x86_64" ] && myArch="linux-x64"
[ "$thisArch" == "aarch64" ] && myArch="linux-arm64"

if [ "$myArch" != "linux-x64" ]; then
  # Better way ?
  curl -fsSL https://get.docker.com -o get-docker.sh
  if [ $UID -eq 0 ]; then
    bash get-docker.sh
    apt install python3-pip -y
	pip3 install --upgrade requests
    pip3 install docker-compose
  else
    sudo bash get-docker.sh
    sudo apt install python3-pip -y
	sudo pip3 install --upgrade requests
    sudo pip3 install docker-compose
	sudo usermod -aG docker $(whoami)
  fi
else
  # Classic way
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
  sudo apt-get update
  sudo apt -y install docker-ce docker-compose
fi
sudo systemctl start docker
sudo systemctl enable docker
# Start ntp and make sure it keeps running (Network Time Protocol)
sudo systemctl start ntp
sudo systemctl enable ntp
sudo usermod -aG docker vagrant
echo "*** Installing Docker... Done"
[ -d /vagrant ] || exit # only continue if vagrant world
echo "Starting docker..."
if [ -e /vagrant/nocron.txt ]; then
  echo "NOT starting Docker (nocron.txt)"
else
  if docker-compose -f /vagrant/$dcFile up -d; then
    echo "Starting docker...DONE"
  else
    echo "Starting docker... FAILED"
  fi
fi
echo "Adding 1 min refresh cron job..."
cat << EOF > /root/dockercompose.sh
#!/bin/bash

# check if we should run
[ -e /vagrant/nocron.txt ] && echo "nocron" > /root/log/docker-compose/\$(date +%M).log && exit
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
[ -d /root/log/docker-compose ] || mkdir -p /root/log/docker-compose
docker-compose -f /vagrant/$dcFile up -d --remove-orphans > /root/log/docker-compose/\$(date +%M).log 2>&1
EOF
crontab -l > cron-temp
cat << EOF >> cron-temp
*/1 * * * * /bin/bash ./dockercompose.sh
EOF
crontab cron-temp
echo "Adding 1 min refresh cron job... DONE"
echo "Adapt Network settings for JGroup..."
cat >> /etc/sysctl.conf << EOF

# Allow a 25MB UDP receive buffer for JGroups
net.core.rmem_max = 26214400
# Allow a 1MB UDP send buffer for JGroups
net.core.wmem_max = 1048576

EOF
sysctl -p
echo "Adapt Network settings for JGroup... DONE"
echo "*** 10_InstallDocker.sh ...DONE"
