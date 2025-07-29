#!/bin/bash

# bashrc-injector.sh
# 自动将常用配置注入到用户的bashrc文件中

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以root权限运行
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "请不要以root权限运行此脚本"
        exit 1
    fi
}

# 获取用户的主目录
get_home_dir() {
    if [[ -n "$HOME" ]]; then
        echo "$HOME"
    else
        echo "$(eval echo ~$USER)"
    fi
}

# 检查bashrc文件是否存在
check_bashrc() {
    local home_dir="$1"
    local bashrc_file="$home_dir/.bashrc"
    
    if [[ ! -f "$bashrc_file" ]]; then
        print_warning "bashrc文件不存在，正在创建..."
        touch "$bashrc_file"
        print_success "已创建bashrc文件: $bashrc_file"
    fi
}

# 检查profile文件是否存在
check_profile() {
    local home_dir="$1"
    local profile_file="$home_dir/.profile"
    
    if [[ ! -f "$profile_file" ]]; then
        print_warning "profile文件不存在，正在创建..."
        touch "$profile_file"
        print_success "已创建profile文件: $profile_file"
    fi
}

# 检查是否已经注入过配置
check_already_injected() {
    local bashrc_file="$1"
    local profile_file="$2"
    local marker="# bashrc-injector: 自动注入的配置"
    
    if grep -q "$marker" "$bashrc_file" 2>/dev/null || grep -q "$marker" "$profile_file" 2>/dev/null; then
        return 0  # 已经注入过
    else
        return 1  # 没有注入过
    fi
}

# 备份bashrc文件
backup_bashrc() {
    local bashrc_file="$1"
    local backup_file="${bashrc_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    cp "$bashrc_file" "$backup_file"
    print_success "已备份bashrc文件到: $backup_file"
}

# 备份profile文件
backup_profile() {
    local profile_file="$1"
    local backup_file="${profile_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    cp "$profile_file" "$backup_file"
    print_success "已备份profile文件到: $backup_file"
}

# 创建USB设备规则文件
create_usb_rules() {
    local rules_file="/etc/udev/rules.d/99-usb_bulk.rules"
    local rules_content='SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0001", MODE:="0666", GROUP="plugdev"'
    
    print_info "正在创建USB设备规则文件..."
    
    # 检查是否已经有规则文件
    if [[ -f "$rules_file" ]]; then
        print_warning "USB规则文件已存在: $rules_file"
        print_info "是否要覆盖现有规则？(y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "跳过USB规则创建"
            return 0
        fi
    fi
    
    # 创建规则文件
    if sudo tee "$rules_file" > /dev/null <<< "$rules_content"; then
        print_success "USB设备规则文件已创建: $rules_file"
        print_info "正在重新加载udev规则..."
        if sudo udevadm control --reload-rules && sudo udevadm trigger; then
            print_success "udev规则已重新加载"
        else
            print_warning "udev规则重新加载失败，请手动执行: sudo udevadm control --reload-rules"
        fi
    else
        print_error "创建USB规则文件失败"
        return 1
    fi
}

# 注入环境变量配置到profile
inject_profile_config() {
    local profile_file="$1"
    
    # 要注入到profile的配置内容（环境变量相关）
    cat >> "$profile_file" << 'EOF'

# bashrc-injector: 自动注入的配置
# 注入时间: $(date)

# 添加本地bin目录到PATH (如果目录存在)
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# bashrc-injector: 配置结束
EOF

    print_success "环境变量配置已成功注入到profile文件"
}

# 注入shell配置到bashrc
inject_bashrc_config() {
    local bashrc_file="$1"
    local home_dir="$2"
    
    # 要注入到bashrc的配置内容（shell特定配置）
    cat >> "$bashrc_file" << EOF

# bashrc-injector: 自动注入的配置
# 注入时间: $(date)

# 初始化zoxide
eval "\$(zoxide init bash)"

# 在 Normal 模式下让 j/k 基于当前输入搜索历史
bind  '"\e[A": history-search-backward'
bind  '"\e[B": history-search-forward'

# 自动同步history
export PROMPT_COMMAND="history -a; history -c; history -r; _zoxide_hook"

# 常用别名
alias cb='colcon build --symlink-install --parallel-workers 8'
alias rlib='rm -rf build log install'
alias vb='vim ~/.bashrc'
alias sb='source ~/.bashrc'
alias extract='$home_dir/club_driver_tool/scripts/auto_extract.sh'

# bashrc-injector: 配置结束
EOF

    print_success "shell配置已成功注入到bashrc文件"
}

# 显示注入的配置
show_injected_config() {
    print_info "已注入的配置包括："
    echo ""
    echo "  📁 .profile 文件 (环境变量):"
    echo "    - PATH环境变量配置"
    echo ""
    echo "  📁 .bashrc 文件 (shell配置):"
    echo "    - zoxide初始化"
    echo "    - 历史搜索绑定 (j/k键)"
    echo "    - 历史自动同步"
      echo "    - colcon构建别名 (cb)"
  echo "    - 清理构建文件别名 (rlib)"
  echo "    - 编辑bashrc别名 (vb)"
  echo "    - 重新加载bashrc别名 (sb)"
  echo "    - 自动提取脚本别名 (extract)"
    echo ""
    echo "  🔧 系统配置:"
    echo "    - USB设备规则 (/etc/udev/rules.d/99-usb_bulk.rules)"
}

# 主函数
main() {
    print_info "开始配置文件注入..."
    
    # 检查权限
    check_root
    
    # 获取主目录
    local home_dir=$(get_home_dir)
    local bashrc_file="$home_dir/.bashrc"
    local profile_file="$home_dir/.profile"
    
    print_info "用户主目录: $home_dir"
    print_info "bashrc文件: $bashrc_file"
    print_info "profile文件: $profile_file"
    
    # 检查配置文件
    check_bashrc "$home_dir"
    check_profile "$home_dir"
    
    # 检查是否已经注入过
    if check_already_injected "$bashrc_file" "$profile_file"; then
        print_warning "检测到已经注入过配置，是否要重新注入？(y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "操作已取消"
            exit 0
        fi
    fi
    
    # 备份原文件
    backup_bashrc "$bashrc_file"
    backup_profile "$profile_file"
    
    # 注入配置
    inject_profile_config "$profile_file"
    inject_bashrc_config "$bashrc_file" "$home_dir"
    
    # 创建USB设备规则
    create_usb_rules
    
    # 显示结果
    show_injected_config
    
    print_success "配置注入完成！"
    print_info "请运行以下命令使配置生效："
    echo "  source ~/.profile"
    echo "  source ~/.bashrc"
    echo "  或者重新登录系统"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 