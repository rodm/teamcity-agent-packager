#!/bin/bash

USER=rodm
REPOSITORY=deb
PACKAGE=teamcity-agent
VERSION=${VERSION:-1.0}
RELEASE=${RELEASE:-1}
PACKAGE_FILENAME=${PACKAGE}_${VERSION}-${RELEASE}_all.deb
UPLOAD_DIR=${UPLOAD_DIR:-build}

DISTRIBUTIONS=lucid,precise,trusty
COMPONENTS=main
ARCHITECTURES=i386,amd64

PUBLISH_URL="https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/pool/main/t/$PACKAGE_FILENAME;deb_distribution=$DISTRIBUTIONS;deb_component=$COMPONENTS;deb_architecture=$ARCHITECTURES"

# upload teamcity-agent_all.deb
curl -T $UPLOAD_DIR/$PACKAGE_FILENAME -u$USER:$API_KEY $PUBLISH_URL

# publish
curl -X POST -u$USER:$API_KEY https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/publish
