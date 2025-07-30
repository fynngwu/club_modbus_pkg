#!/bin/bash

# gpu-power-monitor.sh
# 实时监控AMD GPU的功率、温度、频率等信息

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GPU路径
GPU_HWMON="/sys/class/drm/card1/device/hwmon/hwmon5"

# 检查GPU是否存在
check_gpu() {
    if [[ ! -d "$GPU_HWMON" ]]; then
        echo -e "${RED}[ERROR]${NC} GPU监控路径不存在: $GPU_HWMON"
        exit 1
    fi
}

# 读取GPU功率 (微瓦转换为瓦)
get_power() {
    local power_input=$(cat "$GPU_HWMON/power1_input" 2>/dev/null || echo "0")
    local power_avg=$(cat "$GPU_HWMON/power1_average" 2>/dev/null || echo "0")
    
    # 转换为瓦特 (微瓦 / 1000000)
    local power_input_w=$(echo "scale=2; $power_input / 1000000" | bc -l 2>/dev/null || echo "0")
    local power_avg_w=$(echo "scale=2; $power_avg / 1000000" | bc -l 2>/dev/null || echo "0")
    
    echo "$power_input_w $power_avg_w"
}

# 读取GPU温度 (毫摄氏度转换为摄氏度)
get_temperature() {
    local temp=$(cat "$GPU_HWMON/temp1_input" 2>/dev/null || echo "0")
    local temp_c=$(echo "scale=1; $temp / 1000" | bc -l 2>/dev/null || echo "0")
    echo "$temp_c"
}

# 读取GPU频率 (Hz转换为MHz)
get_frequency() {
    local freq=$(cat "$GPU_HWMON/freq1_input" 2>/dev/null || echo "0")
    local freq_mhz=$(echo "scale=1; $freq / 1000000" | bc -l 2>/dev/null || echo "0")
    echo "$freq_mhz"
}

# 读取GPU电压 (mV转换为V)
get_voltage() {
    local voltage=$(cat "$GPU_HWMON/in0_input" 2>/dev/null || echo "0")
    local voltage_v=$(echo "scale=3; $voltage / 1000" | bc -l 2>/dev/null || echo "0")
    echo "$voltage_v"
}

# 获取GPU使用率 (使用radeontop)
get_utilization() {
    local util=$(radeontop -d - -l 1 2>/dev/null | grep "gpu" | awk '{print $3}' | sed 's/%//' 2>/dev/null || echo "0")
    echo "$util"
}

# 显示GPU信息
show_gpu_info() {
    echo -e "${CYAN}=== AMD GPU 功率监控 ===${NC}"
    echo -e "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "GPU: $(lspci | grep -i vga | cut -d: -f3-)"
    echo ""
}

# 显示实时数据
show_realtime_data() {
    local power_data=$(get_power)
    local power_input=$(echo $power_data | awk '{print $1}')
    local power_avg=$(echo $power_data | awk '{print $2}')
    local temp=$(get_temperature)
    local freq=$(get_frequency)
    local voltage=$(get_voltage)
    local util=$(get_utilization)
    
    echo -e "${BLUE}📊 实时数据:${NC}"
    echo -e "  功率 (当前): ${GREEN}${power_input}W${NC}"
    echo -e "  功率 (平均): ${GREEN}${power_avg}W${NC}"
    echo -e "  温度:        ${YELLOW}${temp}°C${NC}"
    echo -e "  频率:        ${CYAN}${freq}MHz${NC}"
    echo -e "  电压:        ${BLUE}${voltage}V${NC}"
    echo -e "  使用率:      ${RED}${util}%${NC}"
    echo ""
}

# 显示功率状态评估
show_power_status() {
    local power_data=$(get_power)
    local power_input=$(echo $power_data | awk '{print $1}')
    local temp=$(get_temperature)
    
    echo -e "${BLUE}🔋 功率状态评估:${NC}"
    
    # 功率评估
    if (( $(echo "$power_input < 10" | bc -l) )); then
        echo -e "  功率状态: ${GREEN}低功耗模式${NC}"
    elif (( $(echo "$power_input < 30" | bc -l) )); then
        echo -e "  功率状态: ${YELLOW}正常模式${NC}"
    else
        echo -e "  功率状态: ${RED}高功耗模式${NC}"
    fi
    
    # 温度评估
    if (( $(echo "$temp < 50" | bc -l) )); then
        echo -e "  温度状态: ${GREEN}正常${NC}"
    elif (( $(echo "$temp < 70" | bc -l) )); then
        echo -e "  温度状态: ${YELLOW}偏高${NC}"
    else
        echo -e "  温度状态: ${RED}过高${NC}"
    fi
    echo ""
}

# 显示历史趋势
show_trend() {
    echo -e "${BLUE}📈 监控趋势:${NC}"
    echo -e "  按 Ctrl+C 停止监控"
    echo ""
}

# 实时监控模式
monitor_mode() {
    local interval=${1:-2}
    
    echo -e "${CYAN}开始实时监控 (刷新间隔: ${interval}秒)${NC}"
    echo -e "按 Ctrl+C 停止监控"
    echo ""
    
    while true; do
        clear
        show_gpu_info
        show_realtime_data
        show_power_status
        show_trend
        sleep $interval
    done
}

# 单次显示模式
single_shot_mode() {
    show_gpu_info
    show_realtime_data
    show_power_status
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}GPU功率监控工具${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -m, --monitor [间隔]  实时监控模式 (默认2秒)"
    echo "  -s, --single          单次显示模式"
    echo "  -h, --help            显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -m 5               # 每5秒刷新一次"
    echo "  $0 -s                 # 显示一次当前状态"
    echo ""
}

# 主函数
main() {
    # 检查依赖
    if ! command -v bc &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} 需要安装 bc 计算器"
        echo "请运行: sudo apt install bc"
        exit 1
    fi
    
    # 检查GPU
    check_gpu
    
    # 解析参数
    case "${1:-}" in
        -m|--monitor)
            local interval=${2:-2}
            monitor_mode $interval
            ;;
        -s|--single)
            single_shot_mode
            ;;
        -h|--help|"")
            show_help
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} 未知参数: $1"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 