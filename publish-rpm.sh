#!/bin/bash

USER=rodm
REPOSITORY=rpm
PACKAGE=teamcity-agent
VERSION=${VERSION:-1.0}
RELEASE=${RELEASE:-1}
PACKAGE_FILENAME=$PACKAGE-$VERSION-$RELEASE.noarch.rpm
UPLOAD_DIR=${UPLOAD_DIR:-build/RPMS/noarch}

PUBLISH_URL="https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/$PACKAGE_FILENAME"

# upload teamcity-agent.noarch.rpm
curl -s -T $UPLOAD_DIR/$PACKAGE_FILENAME -u$USER:$API_KEY $PUBLISH_URL

# publish
curl -s -X POST -u$USER:$API_KEY https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/publish
