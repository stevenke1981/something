#!/bin/sh

# Set wireless network interface and SSID
WIFI_IFACE="radio0"
SSID="MyMeshNetwork"

# Set mesh network settings
CHANNEL="11"
MESH_IFACE="mesh0"
MESH_SSID="$SSID"
MESH_MODE="mesh"
MESH_MESH_ID="$SSID"
MESH_ENCRYPTION="none"
MESH_FREQ="2462"
MESH_HTMODE="HT20"

# Set batman-adv settings
BAT_IFACE="bat0"
BAT_MESH_IFACE="$MESH_IFACE"
BAT_ALGO="BATMAN_V"
BAT_TRANSMIT_POWER="20"
BAT_MCAST_MODE="enabled"
BAT_FRAGMENTATION="enabled"
BAT_AGGREGATION="enabled"
BAT_MCAST_FANOUT="32"
BAT_MCAST_TTL="64"

# Set IP address and subnet mask
IP_ADDRESS="192.168.1.1"
SUBNET_MASK="255.255.255.0"

# Configure wireless network interface
uci set wireless.$WIFI_IFACE.disabled=0
uci set wireless.$WIFI_IFACE.channel=$CHANNEL
uci set wireless.$WIFI_IFACE.mode=$MESH_MODE
uci set wireless.$WIFI_IFACE.mesh_id=$MESH_MESH_ID
uci set wireless.$WIFI_IFACE.mesh_fwding=1
uci set wireless.$WIFI_IFACE.mesh_rssi_threshold=-80
uci set wireless.$WIFI_IFACE.mesh_auto_open_plinks=1
uci set wireless.$WIFI_IFACE.mesh_ttl=5
uci set wireless.$WIFI_IFACE.encryption=$MESH_ENCRYPTION
uci set wireless.$WIFI_IFACE.mesh_auto_path_sel=0
uci set wireless.$WIFI_IFACE.mesh_auto_root=1
uci set wireless.$WIFI_IFACE.mesh_htmode=$MESH_HTMODE
uci set wireless.$WIFI_IFACE.mesh_channel=$MESH_FREQ
uci set wireless.$WIFI_IFACE.ssid=$SSID
uci commit wireless
wifi

# Configure batman-adv
uci set network.$BAT_IFACE=interface
uci set network.$BAT_IFACE.proto=batadv
uci set network.$BAT_IFACE.multicast_mode=$BAT_MCAST_MODE
uci set network.$BAT_IFACE.fragmentation=$BAT_FRAGMENTATION
uci set network.$BAT_IFACE.aggregation=$BAT_AGGREGATION
uci set network.$BAT_IFACE.mcast_fanout=$BAT_MCAST_FANOUT
uci set network.$BAT_IFACE.mcast_ttl=$BAT_MCAST_TTL
uci commit network

# Configure mesh network interface
uci set network.$MESH_IFACE=interface
uci set network.$MESH_IFACE.proto=batadv
uci set network.$MESH_IFACE.mesh=$MESH_MODE
uci set network.$MESH_IFACE.mesh_id=$MESH_MESH_ID
uci set network.$MESH_IFACE.mesh_fwding=1
uci set network.$MESH_IFACE.mesh_rssi_threshold=-80
uci set network.$MESH_IFACE.mesh_auto_open_plinks=1
uci set network.$MESH_IFACE.mesh_ttl=5
uci set network.$MESH_IFACE.bat_iface=$BAT_IFACE
uci set network.$MESH
