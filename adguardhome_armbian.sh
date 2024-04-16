#!/bin/bash

# 下載AdGuardHome二進制文件
wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz
# 解壓縮二進制文件
tar -xzvf AdGuardHome_linux_arm64.tar.gz

# 移動解壓縮後的文件到 /opt/AdGuardHome 目錄
sudo mv AdGuardHome /opt/

# 創建 AdGuardHome 工作目錄
sudo mkdir -p /opt/AdGuardHome/conf
sudo mkdir -p /opt/AdGuardHome/data

# 賦予執行權限
sudo chmod +x /opt/AdGuardHome/AdGuardHome

# 以非root用戶身份運行AdGuardHome (可選)
sudo /opt/AdGuardHome/AdGuardHome -s install
sudo /opt/AdGuardHome/AdGuardHome -s start

# 或作為root用戶直接運行 (無需上面兩行)
# sudo /opt/AdGuardHome/AdGuardHome

# 防火牆規則 (可選)
# sudo ufw allow 3000/tcp
# sudo ufw allow 53/tcp
# sudo ufw allow 53/udp

echo "AdGuardHome已安裝並運行,請訪問http://您的IP:3000配置"
