#!/bin/bash

# Tab Cloner Firefox Extension 安装脚本

echo "=== Tab Cloner Firefox Extension 安装脚本 ==="
echo ""

# 检查是否安装了 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    echo "请先安装 Node.js: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js 已安装"

# 检查是否安装了 npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm 未安装"
    exit 1
fi

echo "✅ npm 已安装"

# 安装 web-ext
echo "正在安装 web-ext..."
npm install -g web-ext

if [ $? -eq 0 ]; then
    echo "✅ web-ext 安装成功"
else
    echo "❌ web-ext 安装失败"
    exit 1
fi

# 检查项目文件
echo ""
echo "检查项目文件..."

if [ -f "manifest.json" ]; then
    echo "✅ manifest.json 存在"
else
    echo "❌ manifest.json 不存在"
    exit 1
fi

if [ -f "background.js" ]; then
    echo "✅ background.js 存在"
else
    echo "❌ background.js 不存在"
    exit 1
fi

# 创建图标文件（如果不存在）
if [ ! -d "icons" ]; then
    mkdir -p icons
    echo "✅ 创建 icons 目录"
fi

# 检查图标文件
if [ -f "icons/icon.svg" ]; then
    echo "✅ icon.svg 存在"
else
    echo "⚠️  icon.svg 不存在，请手动创建图标文件"
fi

echo ""
echo "=== 安装完成 ==="
echo ""
echo "下一步："
echo "1. 将 icons/icon.svg 转换为 PNG 格式（48x48 和 96x96）"
echo "2. 运行 'web-ext run' 来测试扩展"
echo "3. 运行 'web-ext build' 来构建扩展包"
echo ""
echo "测试方法："
echo "1. 打开 Firefox"
echo "2. 访问 about:debugging"
echo "3. 点击 '此 Firefox'"
echo "4. 点击 '临时载入附加组件'"
echo "5. 选择 manifest.json 文件"
echo ""
echo "使用快捷键 Ctrl+K 来克隆当前标签页！"
