#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=strace
VERSION=4.11
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

#patch -p1 < $CWD/strace-musl.patch
#patch -p1 < $CWD/strace-kernelhdr_3.12.6.patch

CC="$CC $mcf $mldf" \
./configure \
--prefix=/usr 

make $jobs CC="$CC -static" CFLAGS="$mcf" || exit
make install DESTDIR=$PKG

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi

# Strip binaries
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
