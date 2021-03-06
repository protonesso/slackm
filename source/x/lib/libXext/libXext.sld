#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=libXext
VERSION=1.3.2
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2
cd $APP-$VERSION
chown -R root:root .

ac_cv_func__XEatDataWords=yes \
./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man

# Depends on libX11,xproto,xextproto and libxau
make $jobs 
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi
cd $PKG
strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz
