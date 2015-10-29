#!/bin/bash

USER=rodm
REPOSITORY=rpm
PACKAGE=teamcity-agent
VERSION=8.1.5

PUBLISH_URL="https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/$PACKAGE-$VERSION-1.noarch.rpm"

# upload teamcity-agent.noarch.rpm
curl -T build/RPMS/noarch/teamcity-agent-8.1.5-1.noarch.rpm -u$USER:$API_KEY $PUBLISH_URL

# publish
curl -X POST -u$USER:$API_KEY https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/publish
