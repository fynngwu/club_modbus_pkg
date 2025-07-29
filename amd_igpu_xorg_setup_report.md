# AMD核显从Wayland切换到Xorg显示服务器简化指南

## 🎯 问题背景

现代Linux发行版（如Ubuntu 22.04+）默认使用Wayland作为显示服务器，但有时会遇到以下问题：
- 显示模糊或像素化
- 某些应用程序兼容性问题
- 性能不如预期
- 需要更好的硬件加速支持

**解决方案**: 切换到传统的Xorg显示服务器

## 📊 当前系统状态检查

### 1. 检查当前显示服务器
```bash
# 检查当前会话类型
echo $XDG_SESSION_TYPE

# 检查是否支持Wayland
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```

### 2. 检查显卡信息
```bash
# 检查显卡驱动
lspci -k | grep -A 2 -i "VGA"

# 检查当前渲染器
glxinfo | grep "OpenGL renderer"

# 检查AMD核显状态
lspci | grep -i amd
```

## 🔧 从Wayland切换到Xorg的简化步骤

### 步骤1: 修改GDM显示管理器配置

**文件位置**: `/etc/gdm3/custom.conf`

**操作步骤**:
```bash
# 备份原配置文件
sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.backup

# 编辑配置文件
sudo nano /etc/gdm3/custom.conf
```

**配置内容**:
```ini
[daemon]
# 禁用Wayland，强制使用Xorg
WaylandEnable=false

# 可选：禁用自动登录（如果需要）
AutomaticLoginEnable=false
```

**关键说明**:
- `WaylandEnable=false` 是核心配置，告诉GDM禁用Wayland
- 这个设置会影响所有用户，不仅仅是当前用户
- 修改后需要重启系统才能生效
- **无需创建专用的AMD核显配置文件**，使用系统默认的Xorg配置即可

### 步骤2: 重启系统应用配置

```bash
# 重启系统
sudo reboot
```

**重要**: 必须重启系统，简单的注销登录不会应用这些更改。

## 🔍 重启后验证配置

### 1. 验证显示服务器类型
```bash
# 检查当前会话类型
echo $XDG_SESSION_TYPE
# 应该显示: x11

# 检查Xorg进程
ps aux | grep Xorg
```

### 2. 验证AMD核显工作状态
```bash
# 检查渲染器
glxinfo | grep "OpenGL renderer"
# 应该显示: AMD Radeon 780M (GFX1103_R1)

# 检查DRI支持
glxinfo | grep "direct rendering"
# 应该显示: direct rendering: Yes
```

### 3. 检查分辨率设置
```bash
# 查看当前分辨率
xrandr

# 查看支持的显示器
xrandr --listmonitors
```

### 4. 如果分辨率不正确，手动设置
```bash
# 查看可用分辨率
xrandr --output XWAYLAND0 --listmodes

# 设置到推荐分辨率
xrandr --output XWAYLAND0 --mode 1920x1200

# 或者设置到其他可用分辨率
xrandr --output XWAYLAND0 --mode 1920x1080
```

## 🎯 配置效果对比

### Wayland vs Xorg 对比

| 特性 | Wayland | Xorg |
|------|---------|------|
| 显示服务器 | 现代，轻量级 | 传统，成熟 |
| 兼容性 | 部分应用可能有问题 | 几乎所有应用都支持 |
| 性能 | 理论上更好 | 实际使用中更稳定 |
| 配置灵活性 | 有限 | 高度可配置 |
| 硬件加速 | 支持 | 支持（默认配置） |

### 实际效果
- ✅ **解决显示模糊**: Xorg提供更清晰的像素渲染
- ✅ **更好的兼容性**: 几乎所有Linux应用都支持Xorg
- ✅ **硬件加速**: 使用默认配置即可获得硬件加速支持
- ✅ **简单配置**: 只需一个配置项即可完成切换

## 🛠️ 故障排除

### 问题1: 重启后仍使用Wayland
**解决方案**:
```bash
# 检查GDM配置是否正确
cat /etc/gdm3/custom.conf

# 确保WaylandEnable=false存在
# 重新编辑配置文件
sudo nano /etc/gdm3/custom.conf
```

### 问题2: 分辨率不正确
**解决方案**:
```bash
# 查看当前显示器名称
xrandr

# 手动设置分辨率
xrandr --output [显示器名称] --mode [分辨率]

# 例如：
xrandr --output XWAYLAND0 --mode 1920x1200
```

### 问题3: 性能问题
**解决方案**:
```bash
# 检查AMD驱动是否正确加载
lspci -k | grep -A 2 -i "VGA"

# 检查DRI支持
glxinfo | grep "direct rendering"

# 更新AMD驱动（如果需要）
sudo apt update
sudo apt install mesa-utils
```

## 🔄 恢复到默认配置

如果需要恢复到默认的Wayland配置：

```bash
# 1. 备份当前配置
sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.xorg_backup

# 2. 删除Wayland禁用设置，恢复默认
sudo sed -i '/WaylandEnable=false/d' /etc/gdm3/custom.conf

# 3. 重启系统
sudo reboot
```

## 🎉 总结

### 配置完成检查清单
- ✅ GDM配置已修改 (`WaylandEnable=false`)
- ✅ 系统已重启
- ✅ 验证显示服务器为X11
- ✅ 验证AMD核显正常工作
- ✅ 分辨率设置正确

### 预期效果
1. **显示质量**: 更清晰的像素渲染，无模糊现象
2. **兼容性**: 更好的应用程序兼容性
3. **性能**: 稳定的图形性能
4. **简单性**: 最小化配置，使用系统默认设置

### 维护建议
- 定期更新AMD驱动
- 监控系统性能
- 保持系统更新

**配置状态**: ✅ 完成
**显示服务器**: Xorg (X11)
**核显状态**: AMD Radeon 780M 正常工作
**配置复杂度**: 极简（仅需一个配置项）
**总体评估**: 成功从Wayland切换到Xorg，显示效果显著改善！ 