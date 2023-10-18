#!/bin/bash
echo "*** 01_Initalizing.sh UID: $UID ..."
echo "*** Waiting for automatic update to release control"
#
# Waiting to clear automatic update system
# Checking the two lock files before continuing
#
counter=0
verify=0
while [ $verify -lt 2 ]; do
  sleep 5
  if fuser -s /var/lib/apt/lists/lock; then
    echo "Waiting for /var/lib/apt/lists/lock $counter"
    let counter=$counter+5
	verify=0
  fi
  if fuser -s /var/lib/dpkg/lock; then
    echo "Waiting for /var/lib/dpkg/lock $counter"
    let counter=$counter+5
	verify=0
  fi
  let verify=$verify+1
done
echo "*** Waiting for automatic update to release control... OK"
#
# All clear
# Updating the package database which was cleared during Packer
#
echo "*** Updating repositories"
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update -o Acquire::CompressionTypes::Order::=gz
sudo apt-get -y upgrade
echo "*** Updating repositories... Done"
# Make sure ntp, git og nano are all installed
echo "*** Installing minimal utilities (nano git ntp resolvconf net-tools)"
sudo apt-get -y install nano git ntp resolvconf net-tools dos2unix
echo "*** Installing minimal utilities (nano git ntp resolvconf)... Done"
echo "*** Adding 5 min refresh cron job..."
cat << EOF > /root/networkinfo.sh
#!/bin/bash

# runs always
[ -d /root/log/network-info ] || mkdir -p /root/log/network-info
ip a | grep "inet " > /root/log/network-info/\$(date +%M).log 2>&1
EOF
crontab -l > cron-temp
cat << EOF >> cron-temp
*/5 * * * *	/bin/bash ./networkinfo.sh
EOF
crontab cron-temp
echo "*** Adding 5 min refresh cron job... DONE"
if [ -e /vagrant/authorized_keys ]; then
  [ -d /home/vagrant/.ssh ] || mkdir /home/vagrant/.ssh
  cat /vagrant/authorized_keys >> /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh
fi
echo "*** 01_Initalizing.sh ...Done"
