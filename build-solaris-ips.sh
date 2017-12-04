#!/bin/sh

. ./common

BUILD_DIR=build
PKG_DIR=$BUILD_DIR/pkg

rm -rf $BUILD_DIR || exit $?

mkdir -p $BUILD_DIR || exit $?
mkdir -p $PKG_DIR/etc/teamcity-agent
mkdir -p $PKG_DIR/lib/svc/manifest/application
mkdir -p $PKG_DIR/opt/teamcity-agent
mkdir -p $PKG_DIR/usr/share/teamcity-agent

downloadTeamCity
/usr/bin/gtar -xzvf $DOWNLOADS_DIR/$TEAMCITY_FILE -C $BUILD_DIR --strip-components=4 TeamCity/webapps/ROOT/update/$AGENT_FILE

unzip -q $BUILD_DIR/$AGENT_FILE -d $PKG_DIR/opt/teamcity-agent

# copy files
cp src/solaris/agent.sh $PKG_DIR/usr/share/teamcity-agent
cp src/teamcity-agent.conf $PKG_DIR/etc/teamcity-agent
cp src/solaris/teamcity-agent.xml $PKG_DIR/lib/svc/manifest/application

chmod +x $PKG_DIR/usr/share/teamcity-agent/agent.sh
chmod +x $PKG_DIR/opt/teamcity-agent/bin/*.sh

updateBuildAgentProperties \
    $PKG_DIR/opt/teamcity-agent/conf/buildAgent.dist.properties \
    $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

/usr/bin/gsed -i -e 's|^JAVA_HOME=.*|JAVA_HOME=/usr/jdk/instances/jdk1.8.0|g' $PKG_DIR/etc/teamcity-agent/teamcity-agent.conf
/usr/bin/gsed -i -e 's|\r$||g' $PKG_DIR/etc/teamcity-agent/teamcity-agent.properties

# generate manifest
pkgsend generate $PKG_DIR | pkgfmt > $BUILD_DIR/$NAME.p5m.1

# modify manifest
pkgmogrify -v -DVERSION=$VERSION -DRELEASE=$RELEASE $BUILD_DIR/$NAME.p5m.1 src/solaris/teamcity-agent.p5m | pkgfmt > $BUILD_DIR/$NAME.p5m.2
pkglint $BUILD_DIR/$NAME.p5m.2

# create local repository
pkgrepo create $BUILD_DIR/repo
pkgrepo -s $BUILD_DIR/repo set publisher/prefix=com.github.rodm

# publish package to local repository
pkgsend -s $BUILD_DIR/repo publish -d $PKG_DIR $BUILD_DIR/$NAME.p5m.2

# create package archive
pkgrecv -s $BUILD_DIR/repo -a -d $BUILD_DIR/$NAME-$VERSION-$RELEASE.p5p $NAME
