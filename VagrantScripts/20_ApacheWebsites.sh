#!/bin/bash

# In the folder websites
# All files *.conf will be assumed to be website configuration files
# If a www folder is present, then its content will be copied to /var/www/
#
## Example
# Filetree
# |
# +--www1 --- www2
# |   |        |
#    x.conf   y.conf
#     |        |
#     +-www    +-www
#        |        |
#
# lm1.vm.provision "shell", path: "VagrantScripts/20_ApacheWebsites.sh", args: "www1"
#
# lm2.vm.provision "shell", path: "VagrantScripts/20_ApacheWebsites.sh", args: "www2"

if [ -d /vagrant/$1 ]; then
  echo "*** 20_ApacheWebsites.sh [$1]..."
  cd /vagrant/$1
  websites=$(ls -1 *.conf)
  for nn in $websites; do
    cp $nn /etc/apache2/sites-available/
  done
  cd /etc/apache2/sites-enabled/
  for nn in $websites; do
	ln -s ../sites-available/$nn
  done
  # Copy website content in place
  cd /vagrant/$1
  [ -d www ] && cp -a www/* /var/www/
  chmod 755 www/*/*.cgi
  echo "*** 20_ApacheWebsites.sh [$1]...DONE"
else
  echo "*** 20_ApacheWebsites.sh [$1]...FAILED"
fi
systemctl restart apache2
