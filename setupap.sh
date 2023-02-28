#!/bin/sh

# 要求用戶輸入IP地址和子網掩碼
echo "Please enter the IP address for this device (e.g. 192.168.1.1):"
read IP_ADDRESS
echo "Please enter the subnet mask for this device (e.g. 255.255.255.0):"
read SUBNET_MASK

# 關閉DHCP服務
/etc/init.d/dnsmasq disable
/etc/init.d/dnsmasq stop

# 關閉防火牆
/etc/init.d/firewall disable
/etc/init.d/firewall stop

# 關閉dnsmasq
/etc/init.d/dnsmasq disable
/etc/init.d/dnsmasq stop

# 配置網絡接口
uci set network.lan.ipaddr=$IP_ADDRESS
uci set network.lan.netmask=$SUBNET_MASK

# 配置無線網絡
echo "Please enter the SSID for the wireless network:"
read SSID
echo "Please enter the password for the wireless network:"
read PASSWORD

uci set wireless.radio0.disabled=0
uci set wireless.radio0.channel=1
uci set wireless.radio0.hwmode=11g
uci set wireless.radio0.htmode=HT20
uci set wireless.radio0.country=US
uci set wireless.radio0.txpower=17
uci set wireless.radio0.bursting=1
uci set wireless.radio0.short_gi=1
uci set wireless.radio0.wds=1
uci set wireless.radio0.wmm=1
uci set wireless.default_radio0.ssid=$SSID
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=$PASSWORD

# 重新啟動網絡服務
/etc/init.d/network restart

# 顯示配置結果
echo "Network configuration is complete. Please check the settings below:"
uci show network.lan.ipaddr
uci show network.lan.netmask
uci show wireless.default_radio0.ssid
uci show wireless.default_radio0.encryption
