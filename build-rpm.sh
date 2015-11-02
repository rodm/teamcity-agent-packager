#!/bin/sh

NAME=teamcity-agent
VERSION=${VERSION:-1.0}

notfound() {
    echo "$1 command not found"
    exit 1
}

which unzip > /dev/null || notfound unzip
which rpmbuild > /dev/null || notfound rpmbuild

BUILD_DIR=`pwd`/build
DOWNLOADS_DIR=`dirname $0`/downloads

TEAMCITY_URL=${TEAMCITY_URL:-http://download.jetbrains.com/teamcity/TeamCity-9.1.tar.gz}
TEAMCITY_FILE=${TEAMCITY_URL##*/}

# download TeamCity distribution
if [ ! -f $DOWNLOADS_DIR/$TEAMCITY_FILE ]; then
    mkdir -p $DOWNLOADS_DIR
    curl -L $TEAMCITY_URL -o $DOWNLOADS_DIR/$TEAMCITY_FILE || exit $?
fi

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $BUILD_DIR/BUILD
mkdir -p $BUILD_DIR/RPMS
mkdir -p $BUILD_DIR/SRPMS
mkdir -p $BUILD_DIR/SOURCES
mkdir -p $BUILD_DIR/SPECS

AGENT_FILE=buildAgent.zip
tar -xzvf $DOWNLOADS_DIR/$TEAMCITY_FILE -C $BUILD_DIR/SOURCES --strip-components 4 TeamCity/webapps/ROOT/update/$AGENT_FILE

# copy files
cp src/agent.sh $BUILD_DIR/SOURCES
cp src/teamcity-agent.init $BUILD_DIR/SOURCES
cp src/teamcity-agent.conf $BUILD_DIR/SOURCES

unzip -j -d $BUILD_DIR $BUILD_DIR/SOURCES/$AGENT_FILE conf/buildAgent.dist.properties
sed -e "s/\r$//g" \
    -e "s/^workDir=.*/workDir=\/var\/lib\/teamcity-agent\/work/g" \
    -e "s/^tempDir=.*/tempDir=\/var\/lib\/teamcity-agent\/temp/g" \
    -e "s/^systemDir=.*/systemDir=\/var\/lib\/teamcity-agent\/system/g" \
    < $BUILD_DIR/buildAgent.dist.properties \
    > $BUILD_DIR/SOURCES/teamcity-agent.properties

sed -e "s/@NAME@/$NAME/g" \
    -e "s/@VERSION@/$VERSION/g" \
    < src/rpm/teamcity-agent.spec > $BUILD_DIR/SPECS/teamcity-agent.spec

# build rpm package
/usr/bin/rpmbuild \
    --define "_topdir $BUILD_DIR" \
    -bb \
    --clean \
    $BUILD_DIR/SPECS/teamcity-agent.spec

