#!/bin/bash

# 检查是否以 root 运行（非必须但建议）
if [ "$(id -u)" -eq 0 ]; then
    echo "[警告] 不建议以 root 用户运行此脚本，请使用普通用户执行。"
    exit 1
fi

# 输入参数
read -p "请输入远程用户名: " username
read -p "请输入远程服务器IP（多个IP用空格分隔）: " -a ips
read -s -p "请输入SSH登录密码: " password
echo  # 换行

# 检查 sshpass 是否安装
if ! command -v sshpass &> /dev/null; then
    echo "[安装] 正在安装 sshpass..."
    sudo apt-get install -y sshpass || { echo "[错误] 安装 sshpass 失败"; exit 1; }
fi

# 生成 SSH 密钥（如果不存在）
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "[密钥] 生成新的 ed25519 密钥对..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
    echo "[成功] 密钥已生成: ~/.ssh/id_ed25519"
else
    echo "[信息] 使用现有密钥: ~/.ssh/id_ed25519"
fi

# 配置每个服务器
for ip in "${ips[@]}"; do
    echo "===== 正在配置服务器: $username@$ip ====="

    # 上传公钥
    echo "[上传] 将公钥复制到远程服务器..."
    sshpass -p "$password" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519.pub "$username@$ip" || {
        echo "[错误] 公钥上传失败"; continue
    }

    # 修复远程权限
    echo "[权限] 修复远程目录权限..."
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$ip" \
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys && chmod 755 ~" || {
        echo "[警告] 权限修复失败（可能已正确设置）"
    }

    # 测试免密登录
    echo "[测试] 尝试免密登录..."
    ssh -o BatchMode=yes -i ~/.ssh/id_ed25519 "$username@$ip" "echo '[成功] 免密登录配置完成！'" || {
        echo "[错误] 免密登录测试失败"
    }
done
update_ssh_config() {
    local ip="$1"
    local username="$2"
    local config_line="Host $ip\n    HostName $ip\n    User $username\n    IdentityFile ~/.ssh/id_ed25519"

    if [ ! -f ~/.ssh/config ]; then
        echo -e "$config_line" > ~/.ssh/config
        echo "[配置] 创建 ~/.ssh/config 并添加 $ip"
    elif ! grep -q "Host $ip" ~/.ssh/config; then
        echo -e "\n$config_line" >> ~/.ssh/config
        echo "[配置] 追加 $ip 到 ~/.ssh/config"
    else
        echo "[信息] $ip 已在 ~/.ssh/config 中，跳过"
    fi

    # 修复 config 文件权限
    chmod 600 ~/.ssh/config
}

for ip in "${ips[@]}"; do
    update_ssh_config "$ip" "$username"
done
echo "===== 所有服务器配置完成 ====="
