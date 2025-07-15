#!/bin/bash

# 自动解压脚本 - 根据文件后缀名自动选择正确的解压命令
# 使用方法: ./auto_extract.sh <压缩文件路径>

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 帮助信息
show_help() {
    echo -e "${BLUE}自动解压脚本${NC}"
    echo "使用方法: $0 <压缩文件路径>"
    echo ""
    echo "支持的压缩格式:"
    echo "  .zip     - ZIP压缩文件"
    echo "  .tar     - TAR归档文件"
    echo "  .tar.gz  - GZIP压缩的TAR文件"
    echo "  .tgz     - GZIP压缩的TAR文件"
    echo "  .tar.bz2 - BZIP2压缩的TAR文件"
    echo "  .tbz2    - BZIP2压缩的TAR文件"
    echo "  .tar.xz  - XZ压缩的TAR文件"
    echo "  .txz     - XZ压缩的TAR文件"
    echo "  .tar.lzma- LZMA压缩的TAR文件"
    echo "  .tar.lz  - LZMA压缩的TAR文件"
    echo "  .rar     - RAR压缩文件"
    echo "  .7z      - 7-Zip压缩文件"
    echo "  .gz      - GZIP压缩文件"
    echo "  .bz2     - BZIP2压缩文件"
    echo "  .xz      - XZ压缩文件"
    echo "  .lzma    - LZMA压缩文件"
    echo "  .lz      - LZMA压缩文件"
    echo ""
    echo "示例:"
    echo "  $0 archive.zip"
    echo "  $0 data.tar.gz"
    echo "  $0 backup.7z"
}

# 检查文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}错误: 文件 '$1' 不存在${NC}"
        exit 1
    fi
}

# 检查命令是否可用
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}错误: 命令 '$1' 未安装${NC}"
        echo -e "${YELLOW}请安装相应的软件包:${NC}"
        case "$1" in
            unzip) echo "  sudo apt-get install unzip" ;;
            unrar) echo "  sudo apt-get install unrar" ;;
            7z) echo "  sudo apt-get install p7zip-full" ;;
            *) echo "  sudo apt-get install $1" ;;
        esac
        exit 1
    fi
}

# 获取文件扩展名
get_extension() {
    local filename="$1"
    local extension=""
    
    # 处理多重扩展名 (如 .tar.gz, .tar.bz2 等)
    case "$filename" in
        *.tar.gz|*.tgz) extension=".tar.gz" ;;
        *.tar.bz2|*.tbz2) extension=".tar.bz2" ;;
        *.tar.xz|*.txz) extension=".tar.xz" ;;
        *.tar.lzma|*.tar.lz) extension=".tar.lzma" ;;
        *) extension=".${filename##*.}" ;;
    esac
    
    echo "$extension"
}

# 解压文件
extract_file() {
    local file="$1"
    local extension=$(get_extension "$file")
    local filename=$(basename "$file")
    local dirname=$(dirname "$file")
    local basename="${filename%.*}"
    
    # 如果是多重扩展名，需要特殊处理
    if [[ "$extension" == ".tar.gz" || "$extension" == ".tgz" ]]; then
        basename="${filename%.tar.gz}"
        basename="${basename%.tgz}"
    elif [[ "$extension" == ".tar.bz2" || "$extension" == ".tbz2" ]]; then
        basename="${filename%.tar.bz2}"
        basename="${basename%.tbz2}"
    elif [[ "$extension" == ".tar.xz" || "$extension" == ".txz" ]]; then
        basename="${filename%.tar.xz}"
        basename="${basename%.txz}"
    elif [[ "$extension" == ".tar.lzma" || "$extension" == ".tar.lz" ]]; then
        basename="${filename%.tar.lzma}"
        basename="${basename%.tar.lz}"
    fi
    
    echo -e "${BLUE}正在解压: $filename${NC}"
    echo -e "${YELLOW}目标目录: $dirname/${basename}${NC}"
    
    # 创建解压目录
    local extract_dir="$dirname/${basename}"
    mkdir -p "$extract_dir"
    
    # 根据扩展名选择解压命令
    case "$extension" in
        .zip)
            check_command unzip
            echo -e "${GREEN}使用 unzip 解压...${NC}"
            unzip -q "$file" -d "$extract_dir"
            ;;
        .tar)
            echo -e "${GREEN}使用 tar 解压...${NC}"
            tar -xf "$file" -C "$extract_dir"
            ;;
        .tar.gz|.tgz)
            echo -e "${GREEN}使用 tar 解压 gzip 压缩文件...${NC}"
            tar -xzf "$file" -C "$extract_dir"
            ;;
        .tar.bz2|.tbz2)
            echo -e "${GREEN}使用 tar 解压 bzip2 压缩文件...${NC}"
            tar -xjf "$file" -C "$extract_dir"
            ;;
        .tar.xz|.txz)
            echo -e "${GREEN}使用 tar 解压 xz 压缩文件...${NC}"
            tar -xJf "$file" -C "$extract_dir"
            ;;
        .tar.lzma|.tar.lz)
            echo -e "${GREEN}使用 tar 解压 lzma 压缩文件...${NC}"
            tar -xaf "$file" -C "$extract_dir"
            ;;
        .rar)
            check_command unrar
            echo -e "${GREEN}使用 unrar 解压...${NC}"
            unrar x -y "$file" "$extract_dir/"
            ;;
        .7z)
            check_command 7z
            echo -e "${GREEN}使用 7z 解压...${NC}"
            7z x -y "$file" -o"$extract_dir"
            ;;
        .gz)
            echo -e "${GREEN}使用 gunzip 解压...${NC}"
            gunzip -c "$file" > "$extract_dir/${basename}"
            ;;
        .bz2)
            echo -e "${GREEN}使用 bunzip2 解压...${NC}"
            bunzip2 -c "$file" > "$extract_dir/${basename}"
            ;;
        .xz)
            echo -e "${GREEN}使用 unxz 解压...${NC}"
            unxz -c "$file" > "$extract_dir/${basename}"
            ;;
        .lzma|.lz)
            echo -e "${GREEN}使用 unlzma 解压...${NC}"
            unlzma -c "$file" > "$extract_dir/${basename}"
            ;;
        *)
            echo -e "${RED}错误: 不支持的文件格式 '$extension'${NC}"
            echo -e "${YELLOW}支持的格式: .zip, .tar, .tar.gz, .tar.bz2, .tar.xz, .rar, .7z, .gz, .bz2, .xz, .lzma${NC}"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}解压成功!${NC}"
        echo -e "${GREEN}文件已解压到: $extract_dir${NC}"
        
        # 显示解压后的内容
        echo -e "${BLUE}解压后的内容:${NC}"
        ls -la "$extract_dir"
    else
        echo -e "${RED}解压失败!${NC}"
        exit 1
    fi
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ]; then
        echo -e "${RED}错误: 请提供要解压的文件路径${NC}"
        echo ""
        show_help
        exit 1
    fi
    
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    # 检查文件是否存在
    check_file "$1"
    
    # 解压文件
    extract_file "$1"
}

# 运行主函数
main "$@" 