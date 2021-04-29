#!/bin/sh

. ./common

BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $BUILD_DIR/out
mkdir -p $PKG_DIR/opt/teamcity-agent

downloadTeamCity
extractBuildAgent $BUILD_DIR

unzip -q $BUILD_DIR/$AGENT_FILE -d $PKG_DIR/opt/teamcity-agent

# copy properties file
cp $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    $PKG_DIR/opt/teamcity-agent/conf/buildAgent.properties

sed -i .bak -e $'s/\r$//g' $PKG_DIR/opt/teamcity-agent/conf/buildAgent.properties
rm $PKG_DIR/opt/teamcity-agent/conf/buildAgent.properties.bak

mkdir $PKG_DIR/opt/teamcity-agent/logs

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
