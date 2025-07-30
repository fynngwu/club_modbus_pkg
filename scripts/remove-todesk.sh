#!/bin/bash

# remove-todesk.sh
# 彻底删除ToDesk的所有相关内容和启用的服务

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
    if [[ $EUID -ne 0 ]]; then
        print_error "此脚本需要root权限运行"
        print_info "请使用: sudo $0"
        exit 1
    fi
}

# 停止ToDesk服务
stop_todesk_services() {
    print_info "正在停止ToDesk服务..."
    
    # 停止systemd服务
    if systemctl is-active --quiet todeskd.service 2>/dev/null; then
        systemctl stop todeskd.service
        print_success "已停止todeskd.service"
    else
        print_info "todeskd.service未运行"
    fi
    
    # 禁用服务
    if systemctl is-enabled --quiet todeskd.service 2>/dev/null; then
        systemctl disable todeskd.service
        print_success "已禁用todeskd.service"
    else
        print_info "todeskd.service未启用"
    fi
    
    # 杀死ToDesk进程
    local todesk_pids=$(pgrep -f "ToDesk" 2>/dev/null || true)
    if [[ -n "$todesk_pids" ]]; then
        print_info "正在终止ToDesk进程..."
        kill -9 $todesk_pids 2>/dev/null || true
        print_success "已终止ToDesk进程"
    else
        print_info "未发现运行中的ToDesk进程"
    fi
}

# 删除ToDesk文件
remove_todesk_files() {
    print_info "正在删除ToDesk文件..."
    
    # 删除主程序目录
    if [[ -d "/opt/todesk" ]]; then
        rm -rf /opt/todesk
        print_success "已删除 /opt/todesk"
    else
        print_info "/opt/todesk 目录不存在"
    fi
    
    # 删除配置文件目录
    if [[ -d "/etc/todesk" ]]; then
        rm -rf /etc/todesk
        print_success "已删除 /etc/todesk"
    else
        print_info "/etc/todesk 目录不存在"
    fi
    
    # 删除systemd服务文件
    if [[ -f "/etc/systemd/system/todeskd.service" ]]; then
        rm -f /etc/systemd/system/todeskd.service
        print_success "已删除 todeskd.service"
    else
        print_info "todeskd.service 文件不存在"
    fi
    
    # 删除systemd链接
    if [[ -L "/etc/systemd/system/multi-user.target.wants/todeskd.service" ]]; then
        rm -f /etc/systemd/system/multi-user.target.wants/todeskd.service
        print_success "已删除systemd服务链接"
    else
        print_info "systemd服务链接不存在"
    fi
    
    # 删除可执行文件链接
    if [[ -L "/usr/local/bin/todesk" ]]; then
        rm -f /usr/local/bin/todesk
        print_success "已删除 /usr/local/bin/todesk 链接"
    elif [[ -f "/usr/local/bin/todesk" ]]; then
        rm -f /usr/local/bin/todesk
        print_success "已删除 /usr/local/bin/todesk 文件"
    else
        print_info "/usr/local/bin/todesk 不存在"
    fi
}

# 清理用户配置文件
cleanup_user_configs() {
    print_info "正在清理用户配置文件..."
    
    # 清理当前用户的ToDesk配置
    local user_home="$HOME"
    local todesk_configs=(
        "$user_home/.config/todesk"
        "$user_home/.local/share/todesk"
        "$user_home/.cache/todesk"
    )
    
    for config in "${todesk_configs[@]}"; do
        if [[ -e "$config" ]]; then
            rm -rf "$config"
            print_success "已删除 $config"
        else
            print_info "$config 不存在"
        fi
    done
    
    # 清理所有用户的ToDesk配置
    if [[ -d "/home" ]]; then
        for user_dir in /home/*; do
            if [[ -d "$user_dir" ]]; then
                local user_name=$(basename "$user_dir")
                local user_configs=(
                    "$user_dir/.config/todesk"
                    "$user_dir/.local/share/todesk"
                    "$user_dir/.cache/todesk"
                )
                
                for config in "${user_configs[@]}"; do
                    if [[ -e "$config" ]]; then
                        rm -rf "$config"
                        print_success "已删除用户 $user_name 的 $config"
                    fi
                done
            fi
        done
    fi
}

# 清理桌面文件和应用程序菜单
cleanup_desktop_files() {
    print_info "正在清理桌面文件和应用程序菜单..."
    
    # 删除桌面文件
    local desktop_files=(
        "/usr/share/applications/todesk.desktop"
        "/usr/local/share/applications/todesk.desktop"
        "$HOME/.local/share/applications/todesk.desktop"
    )
    
    for desktop_file in "${desktop_files[@]}"; do
        if [[ -f "$desktop_file" ]]; then
            rm -f "$desktop_file"
            print_success "已删除 $desktop_file"
        else
            print_info "$desktop_file 不存在"
        fi
    done
    
    # 删除图标文件
    local icon_files=(
        "/usr/share/icons/hicolor/*/apps/todesk.png"
        "/usr/share/icons/hicolor/*/apps/todesk.svg"
        "/usr/local/share/icons/hicolor/*/apps/todesk.png"
        "/usr/local/share/icons/hicolor/*/apps/todesk.svg"
    )
    
    for icon_pattern in "${icon_files[@]}"; do
        for icon_file in $icon_pattern; do
            if [[ -f "$icon_file" ]]; then
                rm -f "$icon_file"
                print_success "已删除 $icon_file"
            fi
        done
    done
}

# 重新加载systemd
reload_systemd() {
    print_info "正在重新加载systemd..."
    systemctl daemon-reload
    print_success "systemd已重新加载"
}

# 验证清理结果
verify_cleanup() {
    print_info "正在验证清理结果..."
    
    local remaining_items=()
    
    # 检查剩余文件
    if [[ -d "/opt/todesk" ]]; then
        remaining_items+=("/opt/todesk")
    fi
    
    if [[ -d "/etc/todesk" ]]; then
        remaining_items+=("/etc/todesk")
    fi
    
    if [[ -f "/etc/systemd/system/todeskd.service" ]]; then
        remaining_items+=("/etc/systemd/system/todeskd.service")
    fi
    
    if [[ -f "/usr/local/bin/todesk" ]]; then
        remaining_items+=("/usr/local/bin/todesk")
    fi
    
    # 检查进程
    local running_processes=$(pgrep -f "ToDesk" 2>/dev/null || true)
    if [[ -n "$running_processes" ]]; then
        remaining_items+=("运行中的ToDesk进程")
    fi
    
    # 检查服务状态
    if systemctl is-active --quiet todeskd.service 2>/dev/null; then
        remaining_items+=("todeskd.service仍在运行")
    fi
    
    if [[ ${#remaining_items[@]} -eq 0 ]]; then
        print_success "ToDesk已完全清理！"
    else
        print_warning "以下项目仍然存在："
        for item in "${remaining_items[@]}"; do
            echo "  - $item"
        done
    fi
}

# 主函数
main() {
    print_info "开始彻底删除ToDesk..."
    
    # 检查权限
    check_root
    
    # 停止服务
    stop_todesk_services
    
    # 删除文件
    remove_todesk_files
    
    # 清理用户配置
    cleanup_user_configs
    
    # 清理桌面文件
    cleanup_desktop_files
    
    # 重新加载systemd
    reload_systemd
    
    # 验证清理结果
    verify_cleanup
    
    print_success "ToDesk清理完成！"
    print_info "建议重启系统以确保完全清理"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 