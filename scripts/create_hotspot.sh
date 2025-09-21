#!/bin/bash

# --- 配置参数 ---
WIFI_IFACE="wlp3s0" # 请务必根据 nmcli device status 的实际输出修改！
HOTSPOT_NAME="MyUbuntuHotspot"
HOTSPOT_PASSWORD="11111111" # 至少8个字符，最好更长更复杂

echo "--- 准备阶段 ---"

# 0. 确保HOTSPOT_NAME变量在脚本执行环境中有效
export HOTSPOT_NAME="$HOTSPOT_NAME"

# 1. 检查并删除所有同名的旧连接，避免重复和冲突
echo "正在检查并删除旧的同名热点连接 '$HOTSPOT_NAME'..."
# 使用 || true 确保即使没有旧连接，命令也不会失败并中断脚本
if nmcli connection show | grep -q "$HOTSPOT_NAME"; then
    sudo nmcli connection delete "$HOTSPOT_NAME" || true
    echo "  - 旧连接已删除或不存在。"
else
    echo "  - 未发现旧的同名连接 '$HOTSPOT_NAME'。"
fi

# 2. 断开目标无线接口上所有活跃的Wi-Fi连接
echo "正在断开设备 '$WIFI_IFACE' 上所有活跃的Wi-Fi连接..."
ACTIVE_WIFI_CONNS=$(nmcli -t -f UUID,DEVICE,TYPE connection show --active | grep "$WIFI_IFACE" | grep "wifi" | cut -d':' -f1)
if [ -n "$ACTIVE_WIFI_CONNS" ]; then
    for conn_uuid in $ACTIVE_WIFI_CONNS; do
        conn_name=$(nmcli -g NAME connection show $conn_uuid)
        echo "  - 正在断开连接: $conn_name (UUID: $conn_uuid)"
        sudo nmcli connection down uuid "$conn_uuid" || { echo "    断开连接 $conn_name 失败，请手动检查。"; }
    done
else
    echo "  - 未发现设备 '$WIFI_IFACE' 上有活跃的Wi-Fi连接。"
fi

# 3. 解除无线网卡的可能阻塞 (rfkill) - 保持这个，因为它是一个安全措施
echo "正在尝试解除无线网卡阻塞 (rfkill unblock wifi)..."
sudo rfkill unblock wifi


echo "--- 配置热点 ---"

echo "正在创建热点连接 '$HOTSPOT_NAME'..."
sudo nmcli connection add type wifi ifname "$WIFI_IFACE" con-name "$HOTSPOT_NAME" autoconnect yes ssid "$HOTSPOT_NAME" || { echo "创建连接失败"; exit 1; }

echo "正在配置热点模式、IP共享和安全设置..."
sudo nmcli connection modify "$HOTSPOT_NAME" \
    802-11-wireless.mode ap \
    802-11-wireless.band bg \
    ipv4.method shared \
    wifi-sec.key-mgmt wpa-psk \
    wifi-sec.psk "$HOTSPOT_PASSWORD" || { echo "修改连接失败"; exit 1; }

# 设置热点连接的优先级，确保它优先于其他可能的自动连接
# 默认优先级是0，可以设置一个正数使其优先
echo "正在设置热点连接优先级..."
sudo nmcli connection modify "$HOTSPOT_NAME" connection.autoconnect-priority 100


echo "--- 激活与检查 ---"

echo "重启 NetworkManager 服务以应用更改..."
sudo systemctl restart NetworkManager || { echo "重启 NetworkManager 失败"; exit 1; }

echo "等待热点启动..."
sleep 5 # 给NetworkManager一些时间来启动热点

echo "热点配置完成！请检查热点连接 '$HOTSPOT_NAME' 的状态。"
echo "预期设备接口: $WIFI_IFACE"

# 检查热点连接是否活跃
echo "检查 '$HOTSPOT_NAME' 连接是否活跃:"
nmcli connection show --active | grep "$HOTSPOT_NAME"

# 检查设备状态
echo "检查设备 '$WIFI_IFACE' 的状态:"
nmcli device status | grep "$WIFI_IFACE"

# 检查热点IP地址
echo "检查 '$HOTSPOT_NAME' 的 IP 地址 (预计为 10.42.0.1):"
ip addr show "$WIFI_IFACE" | grep -w "inet"

echo "脚本执行完毕。"
