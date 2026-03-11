#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 默认地址
sed -i 's/192.168.1.1/192.168.222.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.222.1/g' package/base-files/luci/bin/config_generate

# 主机名
sed -i 's/LEDE/OpenWrt/g' package/base-files/files/bin/config_generate
sed -i 's/LEDE/OpenWrt/g' package/base-files/luci/bin/config_generate

# 切换内核
sed -i 's/6.6/6.12/g' target/linux/x86/Makefile

#!/bin/bash

#!/bin/bash

echo "===== 设置默认IP ====="

sed -i 's/192.168.1.1/192.168.222.1/g' \
package/base-files/files/bin/config_generate


echo "===== 写入网络配置 ====="

mkdir -p files/etc/config

cat > files/etc/config/network <<'EOF'
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.222.1'
        option netmask '255.255.255.0'
        option ip6assign '64'

config interface 'wan'
        option device 'eth1'
        option proto 'dhcp'

config interface 'wan6'
        option device 'eth1'
        option proto 'dhcpv6'
EOF


echo "===== DHCP服务器 ====="

cat > files/etc/config/dhcp <<'EOF'
config dhcp 'lan'
        option interface 'lan'
        option start '100'
        option limit '150'
        option leasetime '12h'
        option ra 'server'
        option dhcpv6 'server'
        option ra_management '1'

config dhcp 'wan'
        option interface 'wan'
        option ignore '1'
EOF


echo "===== 防火墙默认 ====="

cat > files/etc/config/firewall <<'EOF'
config defaults
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'
EOF


echo "===== NAS自动挂载 ====="

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-mount <<'EOF'
#!/bin/sh
uci set fstab.@global[0].anon_mount='1'
uci set fstab.@global[0].auto_mount='1'
uci commit fstab
exit 0
EOF

chmod +x files/etc/uci-defaults/99-mount


echo "===== 删除SSR轮询 ====="

sed -i '/XHR.poll/d' \
package/*/luci-app-ssr-plus/htdocs/luci-static/resources/view/shadowsocksr/*.js 2>/dev/null || true

sed -i '/setInterval/d' \
package/*/luci-app-ssr-plus/htdocs/luci-static/resources/view/shadowsocksr/*.js 2>/dev/null || true
