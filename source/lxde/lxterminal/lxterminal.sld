#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=lxterminal
VERSION=0.2.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man \
--disable-nls

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
