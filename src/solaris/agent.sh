#!/bin/sh
#
# Start/stop script for TeamCity Build Agent
#

. /etc/teamcity-agent/teamcity-agent.conf

mkdir -p /var/lib/teamcity-agent
mkdir -p /var/log/teamcity-agent
mkdir -p /var/run/teamcity-agent

if [ ! -f $CONFIG_FILE ]; then
    echo "No agent properties file found."
    exit 1
fi

cd /opt/teamcity-agent/bin
exec ./agent.sh $*

