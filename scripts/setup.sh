#!/bin/sh

if [ -f /etc/redhat-release ]; then
    yum -y install rpm-build
else
    apt-get -y update
    apt-get -y install unzip
    apt-get -y install rpm
    apt-get -y install curl
fi
