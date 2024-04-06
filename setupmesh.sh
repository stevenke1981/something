#!/bin/sh

# 提示選擇安裝方式
echo "請選擇安裝方式:"
echo "1) 主節點 (不重新廣播流量)"
echo "2) Mesh節點 (允許重新廣播流量)"
read -p "輸入選項編號 (1 或 2): " option

# 根據選擇設定主節點或mesh節點
case "$option" in
    1)
        mesh_no_rebroadcast='1'
        echo "已設定為主節點,不重新廣播流量"
        ;;
    2)
        mesh_no_rebroadcast='0'
        echo "已設定為mesh節點,允許重新廣播流量"
        ;;
    *)
        echo "無效的選項,請輸入 1 或 2"
        exit 1
        ;;
esac

# 配置mesh參數
uci set wireless.@wifi-iface[0].device='radio0'
uci set wireless.@wifi-iface[0].disabled='0'
uci set wireless.@wifi-iface[0].network='lan'
uci set wireless.@wifi-iface[0].ifname='mesh0'
uci set wireless.@wifi-iface[0].mode='mesh'
uci set wireless.@wifi-iface[0].mesh_id='your-mesh-name'
uci set wireless.@wifi-iface[0].encryption='sae'
uci set wireless.@wifi-iface[0].key='your-secret-password'
uci set wireless.@wifi-iface[0].mesh_no_rebroadcast="$mesh_no_rebroadcast"

# 套用變更
uci commit wireless
wifi

echo "配置完成"
