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
mkdir -p $BUILD_DIR/out
mkdir -p $PKG_DIR/etc/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent
mkdir -p $PKG_DIR/Library/LaunchDaemons

AGENT_FILE=buildAgent.zip
tar -xzvf $DOWNLOADS_DIR/$TEAMCITY_FILE -C $BUILD_DIR --strip-components 4 TeamCity/webapps/ROOT/update/$AGENT_FILE
unzip -q $BUILD_DIR/$AGENT_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp $PKG_DIR/opt/teamcity-agent/bin/jetbrains.teamcity.BuildAgent.plist $PKG_DIR/Library/LaunchDaemons

# update WorkingDirectory in plist file
/usr/libexec/PlistBuddy -c "Set :WorkingDirectory /opt/teamcity-agent" $PKG_DIR/Library/LaunchDaemons/jetbrains.teamcity.BuildAgent.plist

sed -e $'s/\r$//g' \
    -e "s/^workDir=.*/workDir=\/var\/lib\/teamcity-agent\/work/g" \
    -e "s/^tempDir=.*/tempDir=\/var\/lib\/teamcity-agent\/temp/g" \
    -e "s/^systemDir=.*/systemDir=\/var\/lib\/teamcity-agent\/system/g" \
    < $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    > $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

sed -i -e "s/wrapper.app.parameter.10=.*/wrapper.app.parameter.10=\/etc\/teamcity-agent\/teamcity-agent.properties/g" \
    $PKG_DIR/opt/teamcity-agent/launcher/conf/wrapper.conf

chmod +x $PKG_DIR/opt/teamcity-agent/launcher/bin/*

# make the preinstall and postinstall scripts executable
chmod +x src/osx/scripts/*

# build OS X package
pkgbuild --root $PKG_DIR \
         --identifier jetbrains.teamcity.BuildAgent \
         --version $VERSION-$RELEASE \
         --ownership recommended \
         --scripts src/osx/scripts \
         $BUILD_DIR/out/agent.pkg

productbuild --distribution src/osx/distribution.xml \
             --package-path $BUILD_DIR/out \
             --version $VERSION-$RELEASE \
             $BUILD_DIR/teamcity-agent-$VERSION-$RELEASE.pkg
