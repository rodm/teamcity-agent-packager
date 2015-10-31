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
mkdir -p $BUILD_DIR/out
mkdir -p $PKG_DIR/etc/teamcity-agent
mkdir -p $PKG_DIR/usr/share/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent
mkdir -p $PKG_DIR/Library/LaunchDaemons

curl $AGENT_URL -o $BUILD_DIR/$SRC_FILE || exit $?
unzip -q $BUILD_DIR/$SRC_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp src/agent.sh $PKG_DIR/usr/share/teamcity-agent
cp src/teamcity-agent.conf $PKG_DIR/etc/teamcity-agent
cp $PKG_DIR/opt/teamcity-agent/bin/jetbrains.teamcity.BuildAgent.plist $PKG_DIR/Library/LaunchDaemons

## Update WorkingDirectory in plist file:
/usr/libexec/PlistBuddy -c "Set :WorkingDirectory /opt/teamcity-agent" $PKG_DIR/Library/LaunchDaemons/jetbrains.teamcity.BuildAgent.plist

sed -e "s/\r$//g" \
    -e "s/^workDir=.*/workDir=\/var\/lib\/teamcity-agent\/work/g" \
    -e "s/^tempDir=.*/tempDir=\/var\/lib\/teamcity-agent\/temp/g" \
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
         --version $VERSION \
         --ownership recommended \
         --scripts src/osx/scripts \
         $BUILD_DIR/out/agent.pkg

productbuild --distribution src/osx/distribution.xml \
             --package-path $BUILD_DIR/out \
             --version $VERSION \
             $BUILD_DIR/teamcity-agent-$VERSION.pkg
