# Tab Cloner Firefox Extension

一个简单的Firefox扩展，允许用户使用键盘快捷键 `Alt+K` 来克隆当前标签页。

## 功能

- 按下 `Alt+K` 快捷键克隆当前活动标签页
- 新标签页会在当前标签页后面创建并自动激活
- 支持所有类型的网页（HTTP、HTTPS、本地文件等）

## 安装方法

### 临时安装（开发测试）

1. 打开Firefox浏览器
2. 在地址栏输入 `about:debugging`
3. 点击 "此 Firefox"
4. 点击 "临时载入附加组件"
5. 选择项目中的 `manifest.json` 文件

### 正式安装

1. 使用 `web-ext` 工具构建扩展：
   ```bash
   npm install -g web-ext
   web-ext build
   ```

2. 在Firefox中打开 `about:addons`
3. 点击齿轮图标，选择 "从文件安装附加组件"
4. 选择生成的 `.xpi` 文件

## 使用方法

1. 打开任意网页
2. 按下 `Alt+K` 快捷键
3. 当前标签页将被克隆，新标签页会自动打开并激活

## 权限说明

- `tabs`: 用于访问和操作浏览器标签页
- `activeTab`: 用于获取当前活动标签页的信息

## 项目结构

```
tab-cloner-extension/
├── manifest.json      # 扩展配置文件
├── background.js      # 后台脚本
├── icons/            # 图标文件夹
│   └── icon.svg      # SVG图标
├── install.sh        # 安装脚本
└── README.md         # 说明文档
```

## 开发

### 本地开发

使用 `web-ext` 进行本地开发和测试：

```bash
# 安装 web-ext
npm install -g web-ext

# 运行扩展进行测试
web-ext run

# 构建扩展包
web-ext build

# 检查代码
web-ext lint
```

## 技术细节

- 使用 Manifest V2 格式
- 使用 `browser.commands` API 处理键盘快捷键
- 使用 `browser.tabs` API 操作标签页
- 支持事件驱动的后台脚本（非持久化）

## 兼容性

- Firefox 57+
- 支持 Windows、macOS 和 Linux

## 许可证

MIT License 
