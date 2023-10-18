#!/bin/bash

# This script generates certificates for localhost and a wildcard certificate for arguments if any

echo "*** 10_Certificates.sh ..."

DST_FOLDER=~/certificates

[ -e $DST_FOLDER ] || mkdir -p $DST_FOLDER

for nn in localhost $*; do
        [ -e $DST_FOLDER/$nn.crt ] && echo "$nn already exists" && continue
        echo "Creating certificate for $nn"
        mm=$(echo "$nn" | tr '*' 'x')
        echo -e "DK\n\n\n\n\n$nn\nkarsten@jeppesens.com\n" | \
                openssl req -newkey rsa:2048 -nodes -keyout $DST_FOLDER/$mm.key -x509 -days 3650 -out $DST_FOLDER/$mm.crt
done
echo "*** 10_Certificates.sh ...Done"
