#!/bin/bash

pkg_dir=$1

if [ -z $pkg_dir ] || [ ! -d $pkg_dir ]; then
    echo "No package found!" >&2
    exit 0
fi

for pkg in `find $pkg_dir -name '*.ipk' | sort`; do
  name="${pkg##*/}"
  name="${name%%_*}"
  echo "Generating index for package $pkg" >&2
  file_size=$(ls -l $pkg | awk '{print $5}')
  sha256sum=$(sha256sum $pkg | awk '{print $1}')
  sed_safe_pkg=`echo $pkg | sed -e 's/^.///g' -e 's/\//\\\//g'`
  tar -xzOf $pkg ./control.tar.gz | tar xzOf - ./control | sed -e "s/^Description:/Filename: $sed_safe_pkg\
Size: $file_size\
SHA256sum: $sha256sum\
Description:/"
echo ""
done
exit 0