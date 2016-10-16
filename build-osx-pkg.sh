#!/bin/sh

. ./common

BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $BUILD_DIR/out
mkdir -p $PKG_DIR/etc/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent
mkdir -p $PKG_DIR/Library/LaunchDaemons

downloadTeamCity
extractBuildAgent $BUILD_DIR

unzip -q $BUILD_DIR/$AGENT_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp $PKG_DIR/opt/teamcity-agent/bin/jetbrains.teamcity.BuildAgent.plist $PKG_DIR/Library/LaunchDaemons

updateBuildAgentProperties \
    $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

sed -i .bak -e $'s/\r$//g' $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties
rm $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties.bak

# update WorkingDirectory in plist file
/usr/libexec/PlistBuddy -c "Set :WorkingDirectory /opt/teamcity-agent" $PKG_DIR/Library/LaunchDaemons/jetbrains.teamcity.BuildAgent.plist

sed -i .bak -e "s|wrapper.app.parameter.10=.*|wrapper.app.parameter.10=/etc/teamcity-agent/teamcity-agent.properties|g" \
    $PKG_DIR/opt/teamcity-agent/launcher/conf/wrapper.conf
rm $PKG_DIR/opt/teamcity-agent/launcher/conf/wrapper.conf.bak

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
