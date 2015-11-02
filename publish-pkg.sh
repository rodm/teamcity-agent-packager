#!/bin/bash

USER=rodm
REPOSITORY=pkg
PACKAGE=teamcity-agent
VERSION=${VERSION:-1.0}

PUBLISH_URL="https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/$PACKAGE-$VERSION.pkg"

# upload teamcity-agent.pkg
curl -T build/$PACKAGE-$VERSION.pkg -u$USER:$API_KEY $PUBLISH_URL

# publish
curl -X POST -u$USER:$API_KEY https://api.bintray.com/content/$USER/$REPOSITORY/$PACKAGE/$VERSION/publish
