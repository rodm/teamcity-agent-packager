#!/bin/bash

USER=rodm
REPOSITORY=rpm
PACKAGE=teamcity-agent
VERSION=${VERSION:-1.0}

PUBLISH_URL="https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/$PACKAGE-$VERSION-1.noarch.rpm"

# upload teamcity-agent.noarch.rpm
curl -T build/RPMS/noarch/teamcity-agent-$VERSION-1.noarch.rpm -u$USER:$API_KEY $PUBLISH_URL

# publish
curl -X POST -u$USER:$API_KEY https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/publish
