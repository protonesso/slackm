#!/bin/sh

ARCH=x86_64

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=xorg-server
VERSION=1.20.3
PKG=$TMP/package-$APP
BUILD=1sml

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.xz
cd $APP-$VERSION
chown -R root:root .

DEF_FONTPATH="/usr/share/fonts/local,/usr/share/fonts/TTF,/usr/share/fonts/OTF,/usr/share/fonts/Type1,/usr/share/fonts/misc,/usr/share/fonts/CID,/usr/share/fonts/75dpi/:unscaled,/usr/share/fonts/100dpi/:unscaled,/usr/share/fonts/75dpi,/usr/share/fonts/100dpi,/usr/share/fonts/cyrillic"

sed 's@termio.h@termios.h@g' -i 'hw/xfree86/os-support/xf86_OSlib.h' || exit
sleep 2
printf "all:\n\ttrue\ninstall:\n\ttrue\n" > test/Makefile.in || exit
sleep 2

CFLAGS=-D_GNU_SOURCE \
	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--mandir=/usr/man \
	--disable-static \
	--with-xkb-output="/var/lib/xkb" \
	--with-sha1=libnettle \
	--disable-docs \
	--disable-devel-docs \
	--disable-dmx

# X needs udev files. >.>
make $jobs || exit
make install DESTDIR=$PKG || exit

cd $PKG
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
