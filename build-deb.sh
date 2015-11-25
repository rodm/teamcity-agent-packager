#!/bin/sh

. ./common

BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $PKG_DIR/DEBIAN
mkdir -p $PKG_DIR/etc/init.d
mkdir -p $PKG_DIR/etc/teamcity-agent
mkdir -p $PKG_DIR/usr/share/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent

downloadTeamCity
extractBuildAgent $BUILD_DIR

unzip -q $BUILD_DIR/$AGENT_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp src/teamcity-agent.init $PKG_DIR/etc/init.d/teamcity-agent
cp src/agent.sh $PKG_DIR/usr/share/teamcity-agent
cp src/teamcity-agent.conf $PKG_DIR/etc/teamcity-agent

chmod +x $PKG_DIR/etc/init.d/teamcity-agent
chmod +x $PKG_DIR/usr/share/teamcity-agent/agent.sh
chmod +x $PKG_DIR/opt/teamcity-agent/bin/*.sh

updateBuildAgentProperties \
    $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

sed -i -e "s/\r$//g" $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

cp src/deb/* $PKG_DIR/DEBIAN
sed -e "s/@NAME@/$NAME/g" \
    -e "s/@VERSION@/$VERSION/g" \
    -e "s/@RELEASE@/$RELEASE/g" \
    < src/deb/control > $PKG_DIR/DEBIAN/control
chmod 755 $PKG_DIR/DEBIAN/*

# build debian package
dpkg --build $PKG_DIR $BUILD_DIR
