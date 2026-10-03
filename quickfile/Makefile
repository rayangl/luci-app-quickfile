#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=quickfile
PKG_VERSION:=2.0.5
PKG_RELEASE:=1

PKG_SOURCE:=quickfile-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://r2.cooluc.com/source
PKG_HASH:=35f82187dcd8174cdd3021f9d97995b4e70be06f1f8a9c311667bcc93a1f2d63
PKG_BUILD_DIR:=$(BUILD_DIR)/quickfile-src-$(PKG_VERSION)

PKG_MAINTAINER:=sbwml <admin@cooluc.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/quickfile
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Quick File Manager
	DEPENDS:=$(RUST_ARCH_DEPENDS) +liblzma +nginx
	URL:=https://git.cooluc.com/sbwml/quickfile
endef

define Package/quickfile/description
  A high-performance, lightweight web file manager built with Rust (Axum) and Vue 3,
  featuring an integrated terminal and multimedia preview, tailored for embeddedsystems
  and the OpenWrt ecosystem.
endef

CARGO_PKG_VARS += QUICKFILE_VERSION=v$(PKG_VERSION)-r$(PKG_RELEASE)

define Package/quickfile/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/quickfile $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/quickfile.init $(1)/etc/init.d/quickfile

	# 独立 server 配置：只监听 8080，不碰 uHTTPd
	$(INSTALL_DIR) $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) $(CURDIR)/files/nginx/conf.d/quickfile-server.conf \
		$(1)/etc/nginx/conf.d/quickfile-server.conf

	# 路由规则放到独立目录，只有我们自己的 server 引用
	$(INSTALL_DIR) $(1)/etc/nginx/quickfile-locations
	$(INSTALL_CONF) $(CURDIR)/files/quickfile.locations \
		$(1)/etc/nginx/quickfile-locations/quickfile.locations
endef

define Package/quickfile/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	if [ -x /etc/init.d/nginx ]; then
		/etc/init.d/nginx enable 2>/dev/null
		if command -v nginx >/dev/null 2>&1 && nginx -t >/dev/null 2>&1; then
			/etc/init.d/nginx restart 2>/dev/null
		fi
	fi
	/etc/init.d/quickfile enable 2>/dev/null
	/etc/init.d/quickfile restart 2>/dev/null
	echo ""
	echo "QuickFile installed."
	echo "Access: http://<router-ip>:8080/cgi-bin/luci/quickfile"
	echo "Note: LAN only recommended."
	exit 0
}
endef

define Package/quickfile/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/quickfile stop 2>/dev/null
	/etc/init.d/quickfile disable 2>/dev/null
	rm -f /etc/nginx/conf.d/quickfile-server.conf
	rm -rf /etc/nginx/quickfile-locations
	if [ -x /etc/init.d/nginx ] && command -v nginx >/dev/null 2>&1 && nginx -t >/dev/null 2>&1; then
		/etc/init.d/nginx reload 2>/dev/null
	fi
	exit 0
}
endef

$(eval $(call RustBinPackage,quickfile))
$(eval $(call BuildPackage,quickfile))
