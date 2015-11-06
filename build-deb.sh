#!/bin/sh

NAME=teamcity-agent
VERSION=${VERSION:-`head -1 VERSION`}
RELEASE=${RELEASE:-1}

BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg
DOWNLOADS_DIR=`dirname $0`/downloads

TEAMCITY_URL=${TEAMCITY_URL:-http://download.jetbrains.com/teamcity/TeamCity-9.1.tar.gz}
TEAMCITY_FILE=${TEAMCITY_URL##*/}

# download TeamCity distribution
if [ ! -f $DOWNLOADS_DIR/$TEAMCITY_FILE ]; then
    mkdir -p $DOWNLOADS_DIR
    curl -s -L $TEAMCITY_URL -o $DOWNLOADS_DIR/$TEAMCITY_FILE || exit $?
fi

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $PKG_DIR/DEBIAN
mkdir -p $PKG_DIR/etc/init.d
mkdir -p $PKG_DIR/etc/teamcity-agent
mkdir -p $PKG_DIR/usr/share/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent

AGENT_FILE=buildAgent.zip
tar -xzvf $DOWNLOADS_DIR/$TEAMCITY_FILE -C $BUILD_DIR --strip-components 4 TeamCity/webapps/ROOT/update/$AGENT_FILE
unzip -q $BUILD_DIR/$AGENT_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp src/teamcity-agent.init $PKG_DIR/etc/init.d/teamcity-agent
cp src/agent.sh $PKG_DIR/usr/share/teamcity-agent
cp src/teamcity-agent.conf $PKG_DIR/etc/teamcity-agent

chmod +x $PKG_DIR/etc/init.d/teamcity-agent
chmod +x $PKG_DIR/usr/share/teamcity-agent/agent.sh
chmod +x $PKG_DIR/opt/teamcity-agent/bin/*.sh

sed -e "s/\r$//g" \
    -e "s/^workDir=.*/workDir=\/var\/lib\/teamcity-agent\/work/g" \
    -e "s/^tempDir=.*/tempDir=\/var\/lib\/teamcity-agent\/temp/g" \
    -e "s/^systemDir=.*/systemDir=\/var\/lib\/teamcity-agent\/system/g" \
    < $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    > $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

cp src/deb/* $PKG_DIR/DEBIAN
sed -e "s/@NAME@/$NAME/g" \
    -e "s/@VERSION@/$VERSION/g" \
    -e "s/@RELEASE@/$RELEASE/g" \
    < src/deb/control > $PKG_DIR/DEBIAN/control
chmod 755 $PKG_DIR/DEBIAN/*

# build debian package
dpkg --build $PKG_DIR $BUILD_DIR
