#!/bin/bash

# Armbian 網路一鍵安裝腳本 v1.0
# 支持 PPPoE 撥號、DDNS 動態域名和系統安全配置

# 配置區域 - 請根據您的網路環境修改
######### 基礎配置 #########
TIMEZONE="Asia/Taipei"        # 時區設置
HOSTNAME="armbian-router"     # 主機名稱

######### PPPoE 配置 #########
PPPOE_INTERFACE="eth0"        # 網路接口
PPPOE_USERNAME="your_username" # PPPoE 帳號
PPPOE_PASSWORD="your_password" # PPPoE 密碼

######### DDNS 配置 #########
DDNS_PROVIDER="cloudflare"    # DDNS 服務商
DDNS_DOMAIN="yourdomain.com"  # 網域
DDNS_HOSTNAME="home.yourdomain.com" # 完整主機名
DDNS_USERNAME=""               # DDNS 帳號（如果需要）
DDNS_PASSWORD=""               # DDNS API Token

######### 遠程管理配置 #########
SSH_PORT="22"                 # SSH 預設端口
ZEROTIER_NETWORK=""            # Zerotier 網路 ID（可選）

######### 日誌配置 #########
LOG_FILE="/var/log/network_setup.log"

# 日誌記錄函數
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 檢查 root 權限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "錯誤：此腳本必須以 root 權限運行" 
        exit 1
    fi
}

# 系統初始化
system_init() {
    log_message "開始系統初始化..."

    # 更新系統
    apt-get update && apt-get upgrade -y

    # 安裝必要套件
    apt-get install -y \
        pppoe \
        ppp \
        ddclient \
        wget \
        curl \
        vim \
        net-tools \
        htop \
        zsh \
        fail2ban \
        ufw \
        resolvconf

    # 設置主機名
    hostnamectl set-hostname "$HOSTNAME"

    # 設置時區
    timedatectl set-timezone "$TIMEZONE"

    log_message "系統初始化完成"
}

# 配置 PPPoE
configure_pppoe() {
    log_message "配置 PPPoE 連接..."

    # 創建 PPPoE 配置文件
    cat > /etc/ppp/peers/provider << EOF
# PPPoE 連接配置
plugin rp-pppoe.so
interface $PPPOE_INTERFACE
usepeerdns
defaultroute
noauth
user "$PPPOE_USERNAME"
password "$PPPOE_PASSWORD"
persist
maxfail 0
holdoff 30
mtu 1492
mru 1492
EOF

    # 配置 chap-secrets
    cat > /etc/ppp/chap-secrets << EOF
"$PPPOE_USERNAME" * "$PPPOE_PASSWORD" *
EOF
    chmod 600 /etc/ppp/chap-secrets

    # 創建撥號腳本
    cat > /usr/local/bin/pppoe-connect.sh << 'EOF'
#!/bin/bash
# PPPoE 連接腳本

# 等待網路就緒
sleep 30

# 嘗試連接
/usr/sbin/pppd call provider

# 記錄連接日誌
logger "PPPoE connection attempted"
EOF

    chmod +x /usr/local/bin/pppoe-connect.sh

    # 創建 systemd 服務
    cat > /etc/systemd/system/pppoe.service << 'EOF'
[Unit]
Description=PPPoE Auto Connection
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/pppoe-connect.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # 啟用服務
    systemctl enable pppoe
    systemctl start pppoe

    log_message "PPPoE 配置完成"
}

# 配置 DDNS
configure_ddns() {
    log_message "配置 DDNS..."

    # 創建 ddclient 配置文件
    cat > /etc/ddclient.conf << EOF
# DDNS 配置
daemon=300
syslog=yes
retry=30
protocol=$DDNS_PROVIDER
use=web, web=ifconfig.me
ssl=yes

# 域名配置
$DDNS_PROVIDER {
    login=$DDNS_USERNAME
    password=$DDNS_PASSWORD
    $DDNS_HOSTNAME
}
EOF

    chmod 600 /etc/ddclient.conf

    # 重啟 ddclient
    systemctl enable ddclient
    systemctl restart ddclient

    log_message "DDNS 配置完成"
}

# 網路解析配置
configure_resolv() {
    log_message "配置 DNS 解析..."

    # 配置 resolv.conf
    cat > /etc/resolvconf/resolv.conf.d/head << EOF
# 主 DNS 伺服器
nameserver 8.8.8.8
nameserver 1.1.1.1

# 備用 DNS 伺服器
nameserver 208.67.222.222
nameserver 9.9.9.9
EOF

    # 更新 resolv.conf
    resolvconf -u

    log_message "DNS 解析配置完成"
}

# 防火牆配置
configure_firewall() {
    log_message "配置防火牆..."

    # UFW 規則
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw enable

    log_message "防火牆配置完成"
}

# SSH 安全配置
secure_ssh() {
    log_message "加固 SSH 安全性..."

    # 修改 SSH 配置
    sed -i 's/^#Port 22/Port '"$SSH_PORT"'/' /etc/ssh/sshd_config
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # 重啟 SSH 服務
    systemctl restart ssh

    log_message "SSH 安全配置完成"
}

# 遠程管理工具
remote_management() {
    log_message "安裝遠程管理工具..."

    # 安裝 Zerotier
    curl -s https://install.zerotier.com | bash

    # 加入 Zerotier 網路（如果提供了網路 ID）
    if [ -n "$ZEROTIER_NETWORK" ]; then
        zerotier-cli join "$ZEROTIER_NETWORK"
    fi

    log_message "遠程管理工具安裝完成"
}

# 最終系統優化
system_optimize() {
    log_message "系統優化中..."

    # 禁用不必要的服務
    systemctl disable bluetooth
    systemctl disable avahi-daemon

    # 清理套件
    apt-get autoremove -y
    apt-get autoclean

    log_message "系統優化完成"
}

# 主安裝流程
main_install() {
    check_root

    system_init
    configure_pppoe
    configure_ddns
    configure_resolv
    configure_firewall
    secure_ssh
    remote_management
    system_optimize

    log_message "全部配置已完成！請重新啟動系統"
    echo "安裝日誌已記錄在 $LOG_FILE"
}

# 執行安裝
main_install
```

使用說明：

1. 編輯腳本，修改以下關鍵配置：
   - `TIMEZONE`：設置系統時區
   - `HOSTNAME`：設置主機名
   - `PPPOE_INTERFACE`：網路接口
   - `PPPOE_USERNAME` 和 `PPPOE_PASSWORD`：PPPoE 帳號密碼
   - `DDNS_PROVIDER`、`DDNS_DOMAIN`、`DDNS_HOSTNAME`：DDNS 配置
   - `SSH_PORT`：SSH 連接埠
   - `ZEROTIER_NETWORK`：可選的 Zerotier 網路 ID

2. 執行腳本：
```bash
chmod +x network_setup.sh
sudo ./network_setup.sh
```

3. 腳本將：
   - 更新系統
   - 配置 PPPoE 撥號
   - 設定 DDNS
   - 配置防火牆
   - 加固 SSH
   - 安裝遠程管理工具
   - 優化系統

特別注意：
- 需要 root 權限
- 請妥善保管帳號密碼
- 建議使用金鑰登入 SSH
- 務必根據您的網路環境客製化配置

需要我進一步說明或調整腳本嗎？
