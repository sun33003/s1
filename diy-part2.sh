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

echo "========== 写入 IPv6 自动配置 =========="

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

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.222.1'
        option netmask '255.255.255.0'
        option ip6assign '64'

config interface 'wan'
        option device 'eth0'
        option proto 'dhcp'

config interface 'wan6'
        option device 'eth0'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
EOF


echo "========== DHCPv6自动分配 =========="

cat > files/etc/config/dhcp <<'EOF'
config dhcp 'lan'
        option interface 'lan'
        option start '100'
        option limit '150'
        option leasetime '12h'
        option ra 'server'
        option dhcpv6 'server'
        option ra_management '1'
EOF
