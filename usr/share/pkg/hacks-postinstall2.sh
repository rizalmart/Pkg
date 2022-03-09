#!/bin/sh
#another post-install hacks

PKGFILES="$1"

#pm-utils
if [ "$(grep -m 1 "bin/pm\-suspend\-hybrid" "$PKGFILES")" != "" ]; then
 for pmsh in $(grep "bin/pm\-suspend\-hybrid" "$PKGFILES")
 do
 rm -f $pmsh
echo "#!/bin/sh
 exec pm-suspend
" > $pmsh
  chmod +x $pmsh
 done
fi

if [ "$(grep -m 1 "bin/pm\-hibernate" "$PKGFILES")" != "" ]; then
 for pmhib in $(grep "bin/pm\-hibernate" "$PKGFILES")
 do
 rm -f $pmhib
echo "#!/bin/sh
 exec pm-suspend
" > $pmhib
  chmod +x $pmhib
 done
fi

if [ "$(grep -m 1 "bin/startxfce" "$PKGFILES")" != "" ]; then
 for pmhib in $(grep "bin/startxfce" "$PKGFILES")
 do
  rm -f $pmhib
 done
fi

if [ "$(grep -m 1 "bin/xfce4\-session\-logout" "$PKGFILES")" != "" ]; then
 for pmhib in $(grep "bin/xfce4\-session\-logout" "$PKGFILES")
 do
 rm -f $pmhib
echo "#!/bin/sh
 exec shutdown-gui
" > $pmhib
  chmod +x $pmhib
 done
fi


#GVFS

if [ "$(grep -m 1 "/org.gtk.vfs.MTPVolumeMonitor.service" "$PKGFILES")" != "" ]; then
 
 for pmhib in $(grep "/org.gtk.vfs.MTPVolumeMonitor.service" "$PKGFILES")
 do
  mv -f $pmhib ${pmhib}.bak
  echo ${pmhib}.bak >> "$PKGFILES" 
 done

 for pmhib in $(grep "/mtp.monitor" "$PKGFILES")
 do
  mv -f $pmhib ${pmhib}.bak
  echo ${pmhib}.bak >> "$PKGFILES" 
 done

fi


if [ "$(grep -m 1 "/org.gtk.vfs.GPhoto2VolumeMonitor.service" "$PKGFILES")" != "" ]; then
 
 for pmhib in $(grep "/org.gtk.vfs.GPhoto2VolumeMonitor.service" "$PKGFILES")
 do
  mv -f $pmhib ${pmhib}.bak
  echo ${pmhib}.bak >> "$PKGFILES" 
 done

 for pmhib in $(grep "/gphoto2.monitor" "$PKGFILES")
 do
  mv -f $pmhib ${pmhib}.bak
  echo ${pmhib}.bak >> "$PKGFILES" 
 done

fi

if [ "$(grep -m 1 "/org.gtk.vfs.UDisks2VolumeMonitor.service" "$PKGFILES")" != "" ] && [ "$(which pup-volume-monitor)" != "" ]; then
 
 for pmhib in $(grep "/org.gtk.vfs.UDisks2VolumeMonitor.service" "$PKGFILES")
 do
  mv -f $pmhib ${pmhib}.bak
  echo ${pmhib}.bak >> "$PKGFILES" 
 done
 
 for pmhib in $(grep "/udisks2.monitor" "$PKGFILES")
 do
  mv -f $pmhib ${pmhib}.bak
  echo ${pmhib}.bak >> "$PKGFILES" 
 done
 
fi

if [ "$(grep -m 1 "bin/xscreensaver" "$PKGFILES")" != "" ]; then
 
 for pmhib in $(grep "/share/applications/xscreensaver\-properties.desktop" "$PKGFILES")
 do
  sed -i -e 's#^Exec=.*#Exec=xscreensaver\-demo\-shell#g' "$pmhib"
 done
 
 for pmhib in $(grep "/xdg/autostart/xscreensaver.desktop" "$PKGFILES")
 do
  sed -i -e 's#^Exec=.*#Exec=xscreensaver\-wrapper\ \-no\-splash#g' "$pmhib"
 done
 
fi

if [ "$(grep -m 1 "/share/applications/gparted.desktop" "$PKGFILES")" != "" ]; then
 
 for pmhib in $(grep "/share/applications/gparted.desktop" "$PKGFILES")
 do
  [ "$(which gparted_shell)" != "" ] && sed -i -e 's#^Exec=.*#Exec=gparted_shell#g' "$pmhib"
 done
 
fi


if [ "$(grep -m 1 "/etc/profile.d/" "$PKGFILES")" != "" ]; then
 
 for file1 in $(grep "/etc/profile.d/" "$PKGFILES")
 do
  if [ "$file1" != "" ] && [ -f "$file1" ]; then
  
	  case $file1 in
	  *.csh)
	   [ ! -e /bin/csh ] && rm -f "$file1" 
	  ;;
	  *.zsh)
	   [ ! -e /bin/zsh ] && rm -f "$file1" 
	  ;;
	  *.ksh)
	   [ ! -e /bin/ksh ] && rm -f "$file1" 
	  ;;
	  *.dsh|*.dash)
	   [ ! -e /bin/dash ] && rm -f "$file1" 
	  ;;
	  
	  *)
	  
	  for sh1 in csh dash ksh zsh 
	  do	
	   if [ "$(grep -m 1 "/bin/$sh1" "$file1")" != "" ] && [ ! -e /bin/$sh1 ]; then
		 rm -f "$file1"
	   fi
	  done
	   
	  ;;
	  esac
  
  fi
 done
 
 rm -f /etc/profile.d/*.new
 
fi

if [ "$(grep -m 1 "/bin/login" "$PKGFILES")" != "" ]; then
   
   for login1 in $(grep "/bin/login" "$PKGFILES")
   do
    if [ -f $login1 ] && [ "$(file $login1 | grep "ELF ")" != "" ]; then
       rm -f $login1
       ln -s /bin/busybox $login1
    fi
   done
   
fi


if [ "$(echo "$PKGFILES" | grep "glibc")" != "" ]; then
	if [ "$(grep "/libc.so." "$PKGFILES" | grep -E "^\/lib")" != "" ]; then
	 cat /var/packages/package-specs/glibc.specs > /var/packages/package-specs/glibc-so-libs.specs
	 sed -i -e "s#glibc#glibc\-so\-libs#g" /var/packages/package-specs/glibc-so-libs.specs
     grep -E "^\/lib" "$PKGFILES" > /var/packages/builtin_files/glibc-so-libs
    fi
fi

if [ "$(echo "$PKGFILES" | grep "gcc\-g\+\+")" != "" ]; then
	if [ "$(grep -m 1 "/libstdc\+\+" "$PKGFILES")" != "" ]; then
	 cat /var/packages/package-specs/gcc-g++.specs > /var/packages/package-specs/libstdc++.specs
	 sed -i -e "s#gcc\-g\+\+#libstdc\+\+#g" /var/packages/package-specs/libstdc++.specs
     grep "/libstdc\+\+" "$PKGFILES" > /var/packages/builtin_files/libstdc++    
    fi
fi

if [ "$(echo "$PKGFILES" | grep -E "rxvt\-unicode|urxvt")" != "" ]; then

	urxvtpath="$(which urxvt)"
     rxvtpath="$(which rxvt)"
    
    if [ "$rxvtpath" == "" ] && [ "$urxvtpath" != "" ]; then
     dname="$(dirname $urxvtpath)"
     ln -sr $urxvtpath $dname/rxvt
    fi
    
fi


if [ "$(echo "$PKGFILES" | grep "vte")" != "" ]; then
 if [ "$(grep -m 1 "/etc/profile.d/vte.sh" "$PKGFILES")" != "" ]; then
  rm -f /etc/profile.d/vte.sh
 fi   
fi


if [ "$(grep "/opt" "$PKGFILES" | grep "/libexec/QtWebEngineProcess")" != "" ]; then

 for fle in $(grep -E "\.desktop" "$PKGFILES" | tr '\n' ' ')
 do
  sed -i -e "s#^Exec=#Exec=usr-launch\ #g" "$fle"
 done
 
fi


if [ "$(grep -m 1 "/chrome-sandbox" "$PKGFILES")" != "" ] && [ "$(grep -m 1 "/resources/app.asar" "$PKGFILES")" != "" ]; then
 
 for fle in $(grep -E "\.desktop" "$PKGFILES" | tr '\n' ' ')
 do
  sed -i -e "s#^Exec=#Exec=wec-launch\ #g" "$fle"
 done

fi


if [ "$(grep -m 1 "/chrome-sandbox" "$PKGFILES")" != "" ] && [ "$(grep -m 1 "/resources/app/package.json" "$PKGFILES")" != "" ]; then
 
 for fle in $(grep -E "\.desktop" "$PKGFILES" | tr '\n' ' ')
 do
  sed -i -e "s#^Exec=#Exec=wec-launch\ #g" "$fle"
 done

fi


if [ "$(echo "$PKGFILES" | grep -E "chrome|vivaldi|opera|chromium|brave|srware|rekonq|microsoft\-edge|msdge")" != "" ]; then
 
 for fle in $(grep -E "\.desktop" "$PKGFILES" | tr '\n' ' ')
 do
  sed -i -e "s#^Exec=#Exec=wec-launch\ #g" "$fle"
 done

fi
