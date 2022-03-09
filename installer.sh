#!/bin/ash
#Improved by mistfire

export PKGS_DIR=/var/packages
export PKG_DATA_DIR=/root/.pkg

pkgname=pkg-2.0.0-noarch

mkdir -p /tmp/pkg 2>/dev/null

# dont overwrite the existing ${PKG_DATA_DIR}/sources[-all] files, if they exist

for existing_file in ${PKG_DATA_DIR}/sources ${PKG_DATA_DIR}/sources-all ${PKG_DATA_DIR}/sources-user
do
  [ -f "$existing_file" ] && mv "$existing_file" /tmp/pkg/
done

# copy over our new Pkg files

mv /usr/sbin/pkg /usr/sbin/pkg.previous 2>/dev/null

cp -r etc/ root/ sbin/ usr/ / && echo -e "Pkg installed OK \n" || echo -e "Pkg was NOT installed! \n"

# list all Pkg files (not including sources files, cos user might want to keep their added repos)
find etc/ root/ sbin/ usr/ | sed -e 's/^/\//g' > ${PKGS_DIR}/${pkgname}.files

# put the files back again
for existing_file in /tmp/pkg/sources /tmp/pkg/sources-all /tmp/pkg/sources-user
do
  [ -f $existing_file ] && mv $existing_file ${PKG_DATA_DIR}/
done

# fix version and date in man page - get version from recently installed
VER=$(while read ver; do [ "${ver:0:6}" = 'APPVER' ] && ver=${ver#*=} && ver=${ver/\"/} && ver=${ver/\"/} && echo $ver && break;done < /usr/sbin/pkg)
DATE="$(date '+%B %Y')"
sed -e "s/VERSION_PLACEHOLDER/$VER/g" \
	-e "s/DATE_PLACEHOLDER/$DATE/" \
	< usr/share/man/man1/pkg.1 > /usr/share/man/man1/pkg.1

[ -s ${PKGS_DIR}/${pkgname}.files ] && echo -e "Package contents listed in ${PKGS_DIR}/${pkgname}.files \n"

echo -e "Setting up Pkg... \n"

pkg update-sources &>/dev/null

echo
pkg welcome
echo

pkg repo-update && \
{
  sleep 0.1
  echo -e "\nAvailable repos: \n"
  pkg repo-list

  echo
  echo 'For a basic intro, use `pkg welcome`'
  echo 'For more help, use `pkg help`, `pkg help-all` or `pkg usage`'
  echo
}

exit 0
