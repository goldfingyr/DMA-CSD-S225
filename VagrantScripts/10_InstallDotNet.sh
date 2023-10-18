#!/bin/bash
# CAVEAT: We are root @ /home/vagrant
# Installing .Net Core
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-debian
echo "*** Installing .Net Core..."
echo "User: $UID @ $PWD"
wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
wget https://packages.microsoft.com/config/debian/9/prod.list
sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
sudo apt-get update; sudo apt-get install -y apt-transport-https && sudo apt-get update && sudo apt-get install -y dotnet-sdk-5.0 dotnet-sdk-3.1
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
#
# .Net core service script
cat << EOF > /usr/local/bin/dotnetAddService
#!/bin/bash
# Call: dotnetservice <app>
sudo cat << THEEND > /etc/systemd/system/dotnet-\$1.service
[Unit]
Description=.Net Core app \$1

[Service]
WorkingDirectory=/var/www/\$1
ExecStart=/usr/bin/dotnet /var/www/\$1/\$1.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-\$1
User=apache
Environment=ASPNETCORE_ENVIRONMENT=Production 

[Install]
WantedBy=multi-user.target
THEEND
sudo systemctl daemon-reload
sudo systemctl enable \$1
sudo systemctl start \$1 

EOF
chmod 755 /usr/local/bin/dotnetservice
echo "*** Installing .Net Core...DONE"
