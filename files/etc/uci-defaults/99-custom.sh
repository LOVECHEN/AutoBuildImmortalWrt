#!/bin/sh
# 99-custom.sh - ImmortalWrt 首次启动配置脚本
# Beware! This script will be in /rom/etc/uci-defaults/ as part of the image.

# 配置参数
root_password="password"
lan_ip_address="10.10.10.249"
lan_netmask="255.255.240.0"
lan_gateway="10.10.10.251"
lan_dns="10.10.10.251 223.5.5.5 114.114.114.114"

# log potential errors
exec >/tmp/setup.log 2>&1

# 设置 root 密码
if [ -n "$root_password" ]; then
  (echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null
fi

# Configure LAN
if [ -n "$lan_ip_address" ]; then
  uci set network.lan.proto='static'
  uci set network.lan.ipaddr="$lan_ip_address"
  
  if [ -n "$lan_netmask" ]; then
    uci set network.lan.netmask="$lan_netmask"
  fi
  
  if [ -n "$lan_gateway" ]; then
    uci set network.lan.gateway="$lan_gateway"
  fi
  
  if [ -n "$lan_dns" ]; then
    uci set network.lan.dns="$lan_dns"
  fi
  
  uci commit network
fi

# 设置默认防火墙规则，方便单网口虚拟机首次访问 WebUI
uci set firewall.@zone[1].input='ACCEPT'
uci commit firewall

# 设置主机名映射，解决安卓原生 TV 无法联网的问题
uci add dhcp domain
uci set "dhcp.@domain[-1].name=time.android.com"
uci set "dhcp.@domain[-1].ip=203.107.6.88"
uci commit dhcp

# 设置所有网口可访问网页终端
uci -q delete ttyd.@ttyd[0].interface
uci commit ttyd

# 设置所有网口可连接 SSH
uci set dropbear.@dropbear[0].Interface=''
uci commit dropbear

# 设置编译作者信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Packaged by LOVECHEN"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

echo "All done!"
exit 0
