#!/bin/bash
set -ueo pipefail

version=$(git describe --tag)

for linux_arch in 386 amd64
do
    deb_arch=$linux_arch
    [[ "$deb_arch" = "386" ]] && deb_arch=i386
    pkg_name=dockdash-${version}-linux$deb_arch
    env GOOS=linux GOARCH=$linux_arch go build -o build/releases/${pkg_name}/dockdash
    (cd build/releases/${pkg_name} && zip ../../${pkg_name}.zip  dockdash)
    mkdir -p build/releases/${pkg_name}/usr/local/bin
    mv  build/releases/${pkg_name}/dockdash  build/releases/${pkg_name}/usr/local/bin/dockdash
    mkdir -p build/releases/${pkg_name}/DEBIAN
    cat << EOF >  build/releases/${pkg_name}/DEBIAN/control
Package: dockdash
Version: $version
Section: base
Priority: optional
Architecture: $deb_arch
Maintainer: Donal Byrne <byrnedo@tcd.ie>
Description: Docker Terminal Dashboard
 Realtime docker container inspector
EOF
    (cd build/releases && dpkg-deb --build ${pkg_name} && mv ${pkg_name}.deb ../)

done