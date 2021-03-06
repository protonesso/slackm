#!/bin/sh
config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
config etc/mtab.new
config etc/motd.new
config etc/group.new
config etc/csh.login.new
config etc/ld.so.conf.new
config etc/profile.new
config etc/hosts.new
config etc/inputrc.new
config etc/shadow.new
config etc/passwd.new
config etc/printcap.new
config etc/networks.new
config etc/HOSTNAME.new
config etc/gshadow.new
config etc/issue.new
config etc/securetty.new
config etc/shells.new
config etc/services.new
config etc/issue.net.new
config etc/nsswitch.conf.new
config etc/profile.d/lang.csh.new
config etc/profile.d/lang.sh.new
config etc/profile.d/z-dot-in-non-root-path.csh.new
config etc/profile.d/z-dot-in-non-root-path.sh.new
config var/log/lastlog.new
config var/log/wtmp.new
config var/run/utmp.new

if [ -r etc/ld.so.conf.new -a -r etc/ld.so.conf ]; then
  # Ensure that ld.so.conf contains the minimal set of paths:
  cat etc/ld.so.conf | while read pathline ; do
    if ! grep "^${pathline}$" etc/ld.so.conf.new 1> /dev/null 2> /dev/null ; then
      echo "$pathline" >> etc/ld.so.conf.new
    fi
  done
  cp etc/ld.so.conf.new etc/ld.so.conf
fi

# Clean up useless non-examples:
rm -f etc/mtab.new
rm -f etc/motd.new
rm -f etc/ld.so.conf.new
rm -f etc/hosts.new
#rm -f etc/shadow.new
rm -f etc/networks.new
rm -f etc/HOSTNAME.new
#rm -f etc/gshadow.new
rm -f etc/shells.new
rm -f etc/printcap.new
rm -f etc/issue.new
rm -f etc/issue.net.new
#rm -f etc/profile.d/lang.csh.new
#rm -f etc/profile.d/lang.sh.new
rm -f var/run/utmp.new
rm -f var/log/lastlog.new
rm -f var/log/wtmp.new

# Making sure these are there will save us headaches:
if ! grep -q "^dialout:" etc/group ; then
  echo "dialout:x:16:" >> etc/group
fi
if ! grep -q "^audio:" etc/group ; then
  echo "audio:x:17:root,pulse" >> etc/group
fi
if ! grep -q "^video:" etc/group ; then
  echo "video:x:18:" >> etc/group
fi
if ! grep -q "^cdrom:" etc/group ; then
  echo "cdrom:x:19:" >> etc/group
fi
if ! grep -q "^utmp:" etc/group ; then
  echo "utmp:x:22:" >> etc/group
fi
if ! grep -q "^tape:" etc/group ; then
  echo "tape:x:26:" >> etc/group
fi
if ! grep -q "^shadow:" etc/group ; then
  echo "shadow:x:43:" >> etc/group
fi
if ! grep -q "^oprofile:" etc/passwd ; then
  echo "oprofile:x:51:51:oprofile:/:/bin/false" >> etc/passwd
fi
if ! grep -q "^oprofile:" etc/group ; then
  echo "oprofile:x:51:" >> etc/group
fi
if ! grep -q "^usbmux:" etc/passwd ; then
  echo "usbmux:x:52:83:User for usbmux daemon:/var/empty:/bin/false" >> etc/passwd
fi
if ! grep -q "^sddm:" etc/passwd ; then
  echo "sddm:x:64:64:User for SDDM:/var/empty:/bin/false" >> etc/passwd
fi
if ! grep -q "^sddm:" etc/group ; then
  echo "sddm:x:64:" >> etc/group
fi
if ! grep -q "^pulse:" etc/passwd ; then
  echo "pulse:x:65:65:User for PulseAudio:/var/run/pulse:/bin/false" >> etc/passwd
fi
if ! grep -q "^pulse:" etc/group ; then
  echo "pulse:x:65:" >> etc/group
fi
if ! grep -q "^input:" etc/group ; then
  echo "input:x:71:" >> etc/group
fi
if ! grep -q "^apache:" etc/passwd ; then
  echo "apache:x:80:80:User for Apache:/srv/httpd:/bin/false" >> etc/passwd
fi
if ! grep -q "^apache:" etc/group ; then
  echo "apache:x:80:" >> etc/group
fi
if ! grep -q "^messagebus:" etc/passwd ; then
  echo "messagebus:x:81:81:User for D-BUS:/var/run/dbus:/bin/false" >> etc/passwd
fi
if ! grep -q "^messagebus:" etc/group ; then
  echo "messagebus:x:81:" >> etc/group
fi
if ! grep -q "^haldaemon:" etc/passwd ; then
  echo "haldaemon:x:82:82:User for HAL:/var/run/hald:/bin/false" >> etc/passwd
fi
if ! grep -q "^polkitd:" etc/passwd ; then
  echo "polkitd:x:87:87:PolicyKit daemon owner:/var/lib/polkit:/bin/false" >> etc/passwd
fi
if ! grep -q "^haldaemon:" etc/group ; then
  echo "haldaemon:x:82:" >> etc/group
fi
if ! grep -q "^plugdev:" etc/group ; then
  echo "plugdev:x:83:" >> etc/group
fi
if ! grep -q "^power:" etc/group ; then
  echo "power:x:84:" >> etc/group
fi
if ! grep -q "^netdev:" etc/group ; then
  echo "netdev:x:86:" >> etc/group
fi
if ! grep -q "^polkitd:" etc/group ; then
  echo "polkitd:x:87:" >> etc/group
fi
if ! grep -q "^scanner:" etc/group ; then
  echo "scanner:x:93:" >> etc/group
fi

# Also ensure ownerships/perms:
chown root.utmp var/run/utmp var/log/wtmp
chmod 664 var/run/utmp var/log/wtmp
chown root.shadow etc/shadow etc/gshadow
chmod 640 etc/shadow etc/gshadow

if [ ! -r etc/termcap ]; then
 cp -a etc/termcap-Linux etc/termcap
fi

# I don't know why this was ever here, so I better
# leave it, but comment it out
#if [ ! -r etc/passwd.OLD ]; then
#  mv etc/npasswd etc/passwd.OLD
#else
#  rm etc/npasswd
#fi

# Match permissions on any leftover config z-dot-in-non-root-path scripts
# to prevent anyone who turned them on from accidentally losing that setting
# by moving the .new script into place:
if [ -r etc/profile.d/z-dot-in-non-root-path.csh.new ]; then
  touch -r etc/profile.d/z-dot-in-non-root-path.csh etc/profile.d/z-dot-in-non-root-path.csh.new
fi
if [ -r etc/profile.d/z-dot-in-non-root-path.sh.new ]; then
  touch -r etc/profile.d/z-dot-in-non-root-path.sh etc/profile.d/z-dot-in-non-root-path.sh.new
fi

