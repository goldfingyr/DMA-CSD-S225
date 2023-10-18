#!/bin/bash

if [ $# -ne 4 ] || [ ! -e $2/$3/$3.csproj ]; then
  cat << EOF
Usage:
  $0 (-local|<repository>) <Solution> <Project> <ExposedPort>
  $0 -local ScrumGamesFolder ScrumGames 80
  $0 docker.fou.ucnit20.eu MySolutionsFolder MyProjectFolder
  All projects related must be in the same solution folder.
EOF
  exit
fi


cat << EOF > Dockerfile.dotbuild
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE $4
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY $2 ./
RUN dotnet build "$3/$3.csproj" -c Release -o /app/build
FROM build AS publish
RUN dotnet publish "$3/$3.csproj" -c Release -o /app/publish
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "$3.dll"]
### New section
### CHECK_PORTS="mysql:3306 rabbitMQ:5672"
COPY start.dotbuild ./kajestartup.sh
RUN chmod 755 kajestartup.sh
CMD ./kajestartup.sh
RUN ls -l
RUN cat ./kajestartup.sh
EOF

cat << EOF > start.dotbuild
#!/bin/bash
if [ -n "\$CHECK_PORTS" ]; then
  echo "Must check ports before start"
  ! which nc && apt-get update && apt-get -y install netcat
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
fi
if [ -n "\$DOCKER_HOST" ] && grep -qv "KAJE" /etc/hosts; then
  b0=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 21-22)
  b1=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 19-20)
  b2=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 17-18)
  b3=\$(cat /proc/net/route | sed -n '2,2 p' | cut -b 15-16)
  echo "\$((16#\$b0)).\$((16#\$b1)).\$((16#\$b2)).\$((16#\$b3))  \$DOCKER_HOST" >> /etc/hosts
  echo "# KAJE WAS HERE" >> /etc/hosts
fi 
dotnet $3.dll
EOF


tagName=$(echo "$3" | tr '[:upper:]' '[:lower:]')
if [ "$1" != "-local" ]; then
        sudo docker image rm $1/$tagName:latest
        sudo docker image rm $1/$tagName:$(date +%y%m%d)
else
        sudo docker kill $tagName
        sudo docker rm $tagName
        sudo docker image rm $tagName:latest
fi
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