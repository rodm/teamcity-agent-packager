#!/bin/sh

SRC_FILE=buildAgent.zip
BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg
VERSION=4.5.6

rm -rf $PKG_DIR

mkdir -p $PKG_DIR/DEBIAN
mkdir -p $PKG_DIR/etc/init.d
mkdir -p $PKG_DIR/usr/share/teamcity-agent
mkdir -p $PKG_DIR/opt/teamcity-agent
unzip -q $SRC_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp src/teamcity-agent.init $PKG_DIR/etc/init.d/teamcity-agent
cp src/agent.sh $PKG_DIR/usr/share/teamcity-agent
cp src/deb/* $PKG_DIR/DEBIAN

# build debian package
dpkg --build $BUILD_DIR/pkg $BUILD_DIR/teamcity-agent_${VERSION}_all.deb

