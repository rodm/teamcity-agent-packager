#!/bin/sh

. ./common

notfound() {
    echo "$1 command not found"
    exit 1
}

which unzip > /dev/null || notfound unzip
which rpmbuild > /dev/null || notfound rpmbuild

BUILD_DIR=`pwd`/build

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $BUILD_DIR/BUILD
mkdir -p $BUILD_DIR/RPMS
mkdir -p $BUILD_DIR/SRPMS
mkdir -p $BUILD_DIR/SOURCES
mkdir -p $BUILD_DIR/SPECS

downloadTeamCity
extractBuildAgent $BUILD_DIR/SOURCES

# copy files
cp src/agent.sh $BUILD_DIR/SOURCES
cp src/teamcity-agent.init $BUILD_DIR/SOURCES
cp src/teamcity-agent.conf $BUILD_DIR/SOURCES

unzip -j -d $BUILD_DIR $BUILD_DIR/SOURCES/$AGENT_FILE conf/buildAgent.dist.properties
updateBuildAgentProperties \
    $BUILD_DIR/buildAgent.dist.properties \
    $BUILD_DIR/SOURCES/teamcity-agent.properties

sed -i -e "s/\r$//g" $BUILD_DIR/SOURCES/teamcity-agent.properties

sed -e "s/@NAME@/$NAME/g" \
    -e "s/@VERSION@/$VERSION/g" \
    -e "s/@RELEASE@/$RELEASE/g" \
    < src/rpm/teamcity-agent.spec > $BUILD_DIR/SPECS/teamcity-agent.spec

# build rpm package
/usr/bin/rpmbuild \
    --define "_topdir $BUILD_DIR" \
    -bb \
    --clean \
    $BUILD_DIR/SPECS/teamcity-agent.spec
