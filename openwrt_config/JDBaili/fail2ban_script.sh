#!/bin/sh

# 檢查是否已安裝fail2ban
check_and_install_fail2ban() {
    if ! opkg list-installed | grep -q "fail2ban"; then
        echo "Fail2ban未安裝，開始安裝..."
        opkg update
        opkg install fail2ban
        opkg install python3-pyinotify
        
        if [ $? -eq 0 ]; then
            echo "Fail2ban安裝成功"
        else
            echo "Fail2ban安裝失敗，請檢查網絡連接或套件庫"
            exit 1
        fi
    else
        echo "Fail2ban已經安裝"
    fi
}

# 創建jail.d目錄（如果不存在）
create_jail_d_directory() {
    if [ ! -d "/etc/fail2ban/jail.d" ]; then
        mkdir -p "/etc/fail2ban/jail.d"
        echo "已創建 /etc/fail2ban/jail.d 目錄"
    else
        echo "/etc/fail2ban/jail.d 目錄已存在"
    fi
}

# 創建dropbear.local配置文件
create_dropbear_config() {
    CONFIG_PATH="/etc/fail2ban/jail.d/dropbear.local"
    
    if [ ! -f "$CONFIG_PATH" ]; then
        cat > "$CONFIG_PATH" << EOL
[dropbear]
# 啟用此策略
enabled = true

# 使用 dropbear 過濾器來識別登入嘗試
filter = dropbear

# 配置 iptables 動作，指定 SSH 埠為 22，協議為 TCP
action = iptables[port=22, protocol=tcp]

# 系統日誌文件路徑，用於監控登入嘗試
logpath = /tmp/log/system.log

# 最大重試次數，超過 3 次則觸發封鎖
maxretry = 5

# 封鎖時間，這裡設置為 604800 秒（7 天）
bantime = 3600

# 統計重試次數的時間窗口，這裡為 86400 秒（1 天）
findtime = 86400

EOL
        echo "已創建 $CONFIG_PATH 配置文件"
    else
        echo "$CONFIG_PATH 配置文件已存在"
    fi
}

# 啟動和啟用fail2ban服務
start_fail2ban() {
    /etc/init.d/fail2ban enable
    /etc/init.d/fail2ban start
    echo "Fail2ban服務已啟動"
}

# 主程序
main() {
    check_and_install_fail2ban
    create_jail_d_directory
    create_dropbear_config
    start_fail2ban
    
    echo "Fail2ban配置完成"
}

# 執行主程序
main
