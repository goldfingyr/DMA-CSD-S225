#!/bin/bash
# CAVEAT: We are root @ /home/vagrant
# Installing .Net Core
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-debian
#
# CAVEAT: Installing sequence: Docker/Apache
# If Apache is installed subsequently to Docker then Apache will have access to Docker
# See lines below
echo "*** 10_InstallApache.sh ..."
echo "User: $UID @ $PWD"
apt-get -y install apache2 uni2ascii libapache2-mod-auth-openidc
a2enmod headers
a2enmod cgi
a2enmod proxy
a2enmod proxy_http
a2enmod request
a2enmod proxy_wstunnel
a2enmod ssl
a2enmod rewrite
a2enmod auth_openidc
# Enable cgi scripts
sed -i -r "s:#AddHandler cgi-script:AddHandler cgi-script:" /etc/apache2/mods-available/mime.conf
# Allow user "vagrant" access to /var/www
chmod 775 /var/www
chgrp vagrant /var/www
grep -q docker /etc/group && echo "*** Apache granted access to docker system" && sudo usermod -aG docker www-data
echo "*** 10_InstallApache.sh ...DONE"
