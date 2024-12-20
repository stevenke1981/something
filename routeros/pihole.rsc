# 配置容器網絡
/interface/veth/add name=veth1 address=172.17.0.2/24 gateway=172.17.0.1
/interface/bridge/add name=containers
/ip/address/add address=172.17.0.1/24 interface=containers
/interface/bridge/port/add bridge=containers interface=veth1

# 設置 NAT 規則，用於容器的出站流量
/ip/firewall/nat/add chain=srcnat action=masquerade src-address=172.17.0.0/24

# 添加環境變量
/container/envs/add name=pihole_envs key=TZ value="Asia/Taipei"
/container/envs/add name=pihole_envs key=WEBPASSWORD value="co047761816"
/container/envs/add name=pihole_envs key=DNSMASQ_USER value="root"

# 添加掛載點
/container/mounts/add name=etc_pihole src=disk1/etc dst=/etc/pihole
/container/mounts/add name=dnsmasq_pihole src=disk1/etc-dnsmasq.d dst=/etc/dnsmasq.d

# 設置容器配置
/container/config/set registry-url=https://registry-1.docker.io tmpdir=disk1/pull

# 添加 Pi-hole 容器（從 Docker Hub 拉取最新映像）
/container/add remote-image=pihole/pihole:latest interface=veth1 root-dir=disk1/pihole mounts=dnsmasq_pihole,etc_pihole envlist=pihole_envs hostname=PiHole

# 啟動容器
/container/start 0

# 配置端口轉發 (將外部流量轉發到容器)
/ip/firewall/nat/add action=dst-nat chain=dstnat dst-address=192.168.80.240 dst-port=8080 protocol=tcp to-addresses=172.17.0.2 to-ports=80

#delay-time=720

# 將 Pi-hole 設為 DNS 服務器
/ip/dns/set servers=172.17.0.2

# 設置容器自啟動
/container/set 0 start-on-boot=yes
