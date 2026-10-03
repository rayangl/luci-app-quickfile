#!/bin/sh
set -e
if command -v opkg >/dev/null 2>&1; then
    opkg remove luci-app-quickfile quickfile luci-i18n-quickfile-zh-cn 2>/dev/null || true
elif command -v apk >/dev/null 2>&1; then
    apk del luci-app-quickfile quickfile luci-i18n-quickfile-zh-cn 2>/dev/null || true
fi

rm -f /etc/nginx/conf.d/quickfile-server.conf
rm -rf /etc/nginx/quickfile-locations

if command -v nginx >/dev/null 2>&1 && nginx -t >/dev/null 2>&1; then
    /etc/init.d/nginx reload 2>/dev/null || true
fi

echo "卸载完成。Web 后台不受影响。"
