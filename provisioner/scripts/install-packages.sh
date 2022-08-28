#!/bin/bash

yum install -y python3
pip3 install --upgrade pip
yum install -y epel-release
yum install -y snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap

%{ for package in yum_packages ~}
yum install -y ${package}
%{ endfor ~}

%{ for package in pip_packages ~}
pip3 install ${package} --upgrade --user
%{ endfor ~}

systemctl start snapd
%{ for package in snap_packages ~}
snap install ${package} --classic
%{ endfor ~}