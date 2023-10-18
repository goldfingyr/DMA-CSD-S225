#!/bin/bash

# Allows KAJE to connect wo password
echo ""
echo "*** 10_KAJEPublicKey.sh ..."

[ -d /home/vagrant/.ssh ] || mkdir /home/vagrant/.ssh
sshpubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAp52iSR2joMDOy8HWlB3umH9flbnQ+oR2km3Aq3fG34MtkeVllLu/h+KN9q/Y8gfQlL3SJdbFE1S7oVOBtESnGJ9++XxrXUgAPYFqNfJ8vNspYzuLQg2N6izTF+gai5J+GR+pw2m7UeJKDgkrAZocfkgxGfcDmCrOIIhD6mraW47jgDMJtxCHk6tfz0mYj3FOrMGqldW9wv4fTlwDgb1ANAzuqapsncyE7IK0wNav6Ghxq4JbsFEUKR5Q4fGrcK8ULp4W4VnN+XPQyWi3VA+Z62Yh7bab1fvmg4w4up1XmbBQiopLN8LO2n/stlKYEIb977XggZ1sWclIytjjfhhxPw== rsa-key-20170706"
echo "$sshpubkey" >> /home/vagrant/.ssh/authorized_keys

sshpubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA0a9IQWt8MOk19XPbUOkOnAdHdx4duXcU0SPomcCUz5N9Ttq7XW1aCCn/QbpWP8m2Xgjh8AqSCzGZ5rfHT+b4K9fGxULopNDgRArs7vltx/06wujSJ6LA5m+ew1zbNyaoUfDq5tEvJW9ZMtT78Gy6rO1WzGG7tvu4PhlDzFx5M8ZhZakoJ5FShQa0N0HwQamwW8WQ91CE7DYNsfBPgjJLCH1IqKcuvXTxQTKn8D7BWekguCRimBAZ12sjSPWFbtBsvBo8MGFnWntZ5K4sMCTUgys6KE6V1rUsLH66jgt02SwxBwqukAS/RVmLUczDncOjV2x3xjkbg+b/BVnTBb0yUw== rsa-key-20180829"
echo "$sshpubkey" >> /home/vagrant/.ssh/authorized_keys

chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
echo "*** 10_KAJEPublicKey.sh ...DONE"
