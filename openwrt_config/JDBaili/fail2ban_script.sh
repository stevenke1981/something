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
[DEFAULT]
# 封鎖時間
bantime = 3600
# 發現多少次嘗試後封鎖
maxretry = 5
# 偵測時間範圍
findtime = 86400

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
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
