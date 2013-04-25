#!/bin/sh

if [ $# -ne 2 ]; then
    echo "usage: `basename $0` <build agent url> <version>"
    exit 1
fi

AGENT_URL=$1
VERSION=$2

NAME=teamcity-agent
SRC_FILE=buildAgent.zip
BUILD_DIR=`pwd`/build

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $BUILD_DIR/BUILD
mkdir -p $BUILD_DIR/RPMS
mkdir -p $BUILD_DIR/SRPMS
mkdir -p $BUILD_DIR/SOURCES
mkdir -p $BUILD_DIR/SPECS

wget $AGENT_URL -O $BUILD_DIR/SOURCES/$SRC_FILE || exit $?

# copy files
cp src/agent.sh $BUILD_DIR/SOURCES
cp src/teamcity-agent.init $BUILD_DIR/SOURCES
cp src/teamcity-agent.conf $BUILD_DIR/SOURCES

unzip -j -d $BUILD_DIR $BUILD_DIR/SOURCES/$SRC_FILE conf/buildAgent.dist.properties
sed -e "s/\r$//g" \
    < $BUILD_DIR/buildAgent.dist.properties > $BUILD_DIR/SOURCES/teamcity-agent.properties

sed -e "s/@NAME@/$NAME/g" \
    -e "s/@VERSION@/$VERSION/g" \
    < src/teamcity-agent.spec > $BUILD_DIR/SPECS/teamcity-agent.spec

# build rpm package
/usr/bin/rpmbuild \
    --define "_topdir $BUILD_DIR" \
    -bb \
    --clean \
    $BUILD_DIR/SPECS/teamcity-agent.spec

