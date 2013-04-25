#!/bin/sh

if [ $# -ne 2 ]; then
    echo "usage: `basename $0` <build agent url> <version>"
    exit 1
fi

AGENT_URL=$1
VERSION=$2

NAME=teamcity-agent
SRC_FILE=buildAgent.zip
BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $PKG_DIR/DEBIAN
mkdir -p $PKG_DIR/etc/init.d
mkdir -p $PKG_DIR/usr/share/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent

wget $AGENT_URL -O $BUILD_DIR/$SRC_FILE || exit $?
unzip -q $BUILD_DIR/$SRC_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp src/teamcity-agent.init $PKG_DIR/etc/init.d/teamcity-agent
cp src/agent.sh $PKG_DIR/usr/share/teamcity-agent
cp src/teamcity-agent.conf $PKG_DIR/etc
sed -e "s/\r$//g" \
    < $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    > $PKG_DIR/etc/teamcity-agent.properties

cp src/deb/* $PKG_DIR/DEBIAN
sed -e "s/@VERSION@/$VERSION/g" -e "s/@NAME@/$NAME/g" < src/deb/control > $PKG_DIR/DEBIAN/control
chmod 755 $PKG_DIR/DEBIAN/*

# build debian package
dpkg --build $PKG_DIR $BUILD_DIR

