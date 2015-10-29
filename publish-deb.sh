#!/bin/bash

USER=rodm
REPOSITORY=deb
PACKAGE=teamcity-agent
VERSION=8.1.5

DISTRIBUTIONS=lucid,precise,trusty
COMPONENTS=main
ARCHITECTURES=i386,amd64

PUBLISH_URL="https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/pool/main/t/${PACKAGE}_${VERSION}_all.deb;deb_distribution=$DISTRIBUTIONS;deb_component=$COMPONENTS;deb_architecture=$ARCHITECTURES"

# upload teamcity-agent_all.deb
curl -T build/${PACKAGE}_${VERSION}_all.deb -u$USER:$API_KEY $PUBLISH_URL

# publish
curl -X POST -u$USER:$API_KEY https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/publish
