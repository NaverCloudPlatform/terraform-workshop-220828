#!/bin/bash

yum install -y sshpass

rm -f /root/.ssh/id_rsa*
ssh-keygen -t rsa -q -N '' -f $HOME/.ssh/id_rsa

%{ for key, value in servers ~}
sshpass -p '${rootpws[key]}' ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@${value.private_ip}
%{ endfor ~}
