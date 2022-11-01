#!/bin/bash

shopt -s extglob
rm -rf feeds/custom/{diy,mt-drivers,shortcut-fe,luci-app-mtwifi,base-files}

for ipk in $(find feeds/custom/* -maxdepth 0 -type d);
do
	[[ "$(grep "KernelPackage" "$ipk/Makefile")" && ! "$(grep "BuildPackage" "$ipk/Makefile")" ]] && rm -rf $ipk || true
done

rm -rf package/{base-files,network/config/firewall,network/services/dnsmasq,network/services/ppp,system/opkg,libs/mbedtls}
rm -Rf feeds/luci/{applications,collections,protocols,themes,libs,docs,contrib}
rm -Rf feeds/luci/modules/!(luci-base)
# rm -rf feeds/packages/libs/!(libev|c-ares|cjson|boost|lib*|expat|tiff|freetype|udns|pcre2)
rm -Rf feeds/packages/!(lang|libs|devel|utils|net|multimedia)
rm -Rf feeds/packages/multimedia/!(gstreamer1)
rm -Rf feeds/packages/utils/!(pcsc-lite|xz)
rm -Rf feeds/packages/net/!(mosquitto|curl)
rm -Rf feeds/base/package/{kernel,firmware}
rm -Rf feeds/base/package/network/!(services|utils)
rm -Rf feeds/base/package/network/services/!(ppp)
rm -Rf feeds/base/package/network/utils/!(iwinfo|iptables)
rm -Rf feeds/base/package/utils/!(util-linux|lua)
rm -Rf feeds/base/package/system/!(opkg|ubus|uci)

./scripts/feeds update -a
./scripts/feeds install -a -p custom
./scripts/feeds install -a
./lang.sh
sed -i 's/\(page\|e\)\?.acl_depends.*\?}//' `find package/feeds/custom/luci-*/luasrc/controller/* -name "*.lua"`
sed -i 's/\/cgi-bin\/\(luci\|cgi-\)/\/\1/g' `find package/feeds/custom/luci-*/ -name "*.lua" -or -name "*.htm*" -or -name "*.js"` &
sed -i 's/Os/O2/g' include/target.mk
#rm -rf ./feeds/packages/lang/golang
#svn co https://github.com/immortalwrt/packages/trunk/lang/golang feeds/packages/lang/golang

sed -i '/root:/c\root:$1$tTPCBw1t$ldzfp37h5lSpO9VXk4uUE\/:18336:0:99999:7:::' package/feeds/custom/base-files/files/etc/shadow
sed -i "s/tty1::askfirst/tty1::respawn/g" target/linux/*/base-files/etc/inittab

sed -i \
	-e "s/+\(luci\|luci-ssl\|uhttpd\)\( \|$\)/\2/" \
	-e "s/+nginx\( \|$\)/+nginx-ssl\1/" \
	-e 's/+python\( \|$\)/+python3/' \
	-e 's?../../lang?$(TOPDIR)/feeds/packages/lang?' \
	-e 's,$(STAGING_DIR_HOST)/bin/upx,upx,' \
	package/feeds/custom/*/Makefile

date=`(date +“%Y%m%d”)`
sed -i -e "/\(# \)\?REVISION:=/c\REVISION:=$date" -e '/VERSION_CODE:=/c\VERSION_CODE:=$(REVISION)' include/version.mk

cp -f devices/common/.config .config
mv feeds/base feeds/base.bak
mv feeds/packages feeds/packages.bak
make defconfig
rm -Rf tmp
mv feeds/base.bak feeds/base
mv feeds/packages.bak feeds/packages
sed -i 's/CONFIG_ALL=y/CONFIG_ALL=n/' .config
sed -i '/PACKAGE_kmod-/d' .config

sed -i "/mediaurlbase/d" package/feeds/*/luci-theme*/root/etc/uci-defaults/*

sed -i '/WARNING: Makefile/d' scripts/package-metadata.pl

if [ -f /usr/bin/python ]; then
	ln -sf /usr/bin/python staging_dir/host/bin/python
else
	ln -sf /usr/bin/python3 staging_dir/host/bin/python
fi
ln -sf /usr/bin/python3 staging_dir/host/bin/python3
cp -f devices/common/po2lmo staging_dir/host/bin/po2lmo
chmod +x staging_dir/host/bin/po2lmo
