#!/bin/bash

echo "Version 2022.10.15 1446"

if [ $# -ne 4 ] || [ ! -e $2/$3/$3.csproj ]; then
  cat << EOF
Usage:
  $0 (-local|<repository>) <Solution> <Project> <ExposedPort>
  $0 -local ScrumGamesFolder ScrumGames 80
  $0 docker.fou.ucnit20.eu MySolutionsFolder MyProjectFolder
  All projects related must be in the same solution folder.
  Please be just outside solution folder
EOF
  exit
fi

RUNDIR=$pwd
thisArch=$(uname -m)
myRuntime="UNKNOWN"
[ "$thisArch" == "x86_64" ] && myRuntime="linux-x64"
[ "$thisArch" == "aarch64" ] && myRuntime="linux-arm64"

# Dockerfile.dotbuild is executed from parent of solution
# $2 solution folder
# $3 Project folder
cat << EOF > Dockerfile.dotbuild
# Version 22.10.15 1
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE $4

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY $2 ./
RUN pwd
RUN dotnet restore "$3/$3.csproj"
RUN dotnet build "$3/$3.csproj" -c Release --self-contained --runtime $myRuntime -o /app/build
RUN ls -lR /app

FROM build AS publish
RUN dotnet publish "$3/$3.csproj" -c Release --self-contained --runtime $myRuntime -o /app/publish
RUN ls -lR /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "$3.dll"]
### New section
### CHECK_PORTS="mysql:3306 rabbitMQ:5672"
COPY start.dotbuild ./kajestartup.sh
RUN chmod 755 kajestartup.sh
CMD ./kajestartup.sh
RUN pwd
RUN ls -l
RUN cat ./kajestartup.sh
EOF

cat << EOF > start.dotbuild
#!/bin/bash
echo "Version 22.10.15 1446"
if [ -n "\$CHECK_PORTS" ]; then
  echo "Must check ports before start"
  ! which nc >/dev/null && apt-get update && apt-get -y install netcat
  for nn in \$(echo "\$CHECK_PORTS" | tr ';' ' '); do
    xHost=\$(echo "\$nn" | cut -f 1 -d ':')
    xPort=\$(echo "\$nn" | cut -f 2 -d ':')
    echo "Checking Host: \$xHost  Port: \$xPort"
    while ! nc -z -v \$xHost \$xPort; do
      echo "Waiting for Host: \$xHost  Port: \$xPort"
      sleep 5
    done
    echo "Checking Host: \$xHost  Port: \$xPort ... OK"
  done
  echo "Checking ports done..."
fi
# Adding DOCKER_HOST will cause an entry in /etc/hosts for local access to host platform
if [ -n "\$DOCKER_HOST" ] && grep -qv "KAJE" /etc/hosts; then
  echo "Adding DOCKER_HOST to /etc/hosts"
  b0=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 21-22)
  b1=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 19-20)
  b2=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 17-18)
  b3=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 15-16)
  echo "\$((16#\$b0)).\$((16#\$b1)).\$((16#\$b2)).\$((16#\$b3))  \$DOCKER_HOST" >> /etc/hosts
  echo "# KAJE WAS HERE" >> /etc/hosts
  echo "Changed /etc/hosts:"
  cat /etc/hosts
fi
echo "Starting: \$(date)"
dotnet $3.dll
[ "\$ZOMBIE" == "YES" ] && echo "ZOMBIE STATE ENTERED" && sleep 1d
EOF

# We are just outside solution folder
tagName=$(echo "$3" | tr '[:upper:]' '[:lower:]')
if [ "$1" != "-local" ]; then
  sudo docker image rm $1/$tagName:latest
  sudo docker image rm $1/$tagName:$(date +%y%m%d)
else
  sudo docker kill $tagName
  sudo docker rm $tagName
  sudo docker image rm $tagName:latest
fi
pwd
if [ -e $2/$3/$3.csproj ]; then
  echo "Project file OK"
else
  echo "Project file NOK"
  exit
fi
echo "--------------"
cat ./Dockerfile.dotbuild
echo "--------------"

sudo docker build --file ./Dockerfile.dotbuild --tag=$tagName:latest .
if [ "$1" != "-local" ]; then
  sudo docker image tag $tagName:latest $1/$tagName:latest
  sudo docker image tag $tagName:latest $1/$tagName:$(date +%y%m%d)
  sudo docker image ls
  echo "Pushing images to repository"
  sudo docker login $1 --username=pabd --password=12tf56so
  sudo docker push $1/$tagName:latest
  sudo docker push $1/$tagName:$(date +%y%m%d)
fi
echo "Done..."



# docker build -t docker.fou.ucnit20.eu/InputService.Web:latest .
# sudo docker build --file=/vagrant/Dockerfiles/Dockerfile.InputService.Web --tag=docker.fou.ucnit20.eu/inputservice.web:latest .
# docker run -d -p 15001:80 --name inputservice.web docker.fou.ucnit20.eu/inputservice.web:latest

