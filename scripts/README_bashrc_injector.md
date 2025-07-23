# bashrc-injector.sh 使用说明

## 功能描述

`bashrc-injector.sh` 是一个自动化脚本，用于将常用的bash配置自动注入到用户的 `.bashrc` 文件中。

## 注入的配置内容

脚本会自动注入以下配置：

1. **PATH环境变量配置**
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

2. **zoxide初始化**
   ```bash
   eval "$(zoxide init bash)"
   ```

3. **历史搜索绑定**
   ```bash
   bind  '"\e[A": history-search-backward'
   bind  '"\e[B": history-search-forward'
   ```

4. **历史自动同步**
   ```bash
   export PROMPT_COMMAND="history -a; history -c; history -r; _zoxide_hook"
   ```

5. **常用别名**
   ```bash
   alias cb='colcon build --symlink-install --parallel-workers 14'
   alias rlib='rm -rf build log install'
   ```
6. **USB设备规则**
   ```bash
   # 创建USB设备规则文件
   sudo nano /etc/udev/rules.d/99-usb_bulk.rules
   
   # 规则内容
   SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0001", MODE:="0666", GROUP="plugdev"
   ```
7. **修改密码**
   ```bash
   echo "{用户名}:kl;'" | sudo chpasswd
   ```

## 使用方法

### 1. 运行脚本
```bash
./scripts/bashrc-injector.sh
```

### 2. 使配置生效
运行脚本后，执行以下命令使配置立即生效：
```bash
source ~/.bashrc
```
或者重新打开终端。

## 脚本特性

### 安全特性
- **自动备份**: 在修改前会自动备份原有的 `.bashrc` 文件
- **重复检查**: 检测是否已经注入过配置，避免重复注入
- **权限检查**: 不允许以root权限运行，确保安全

### 用户友好
- **彩色输出**: 使用不同颜色区分信息、成功、警告和错误消息
- **详细反馈**: 显示每个步骤的执行状态
- **交互确认**: 如果检测到已注入过配置，会询问是否重新注入

### 错误处理
- **文件检查**: 自动检查 `.bashrc` 文件是否存在，不存在则创建
- **错误退出**: 遇到错误时自动退出，避免部分执行

## 备份文件

脚本会在用户主目录下创建备份文件，格式为：
```
~/.bashrc.backup.YYYYMMDD_HHMMSS
```

## 注意事项

1. **不要以root权限运行**: 脚本会检查并拒绝以root权限运行
2. **备份重要**: 虽然脚本会自动备份，但建议在运行前手动备份重要的配置文件
3. **依赖检查**: 脚本注入的配置中，`zoxide` 需要预先安装才能正常工作

## 故障排除

### 如果脚本运行失败
1. 检查是否有足够的权限访问 `.bashrc` 文件
2. 确认不是以root权限运行
3. 检查磁盘空间是否充足

### 如果配置不生效
1. 确认已经运行了 `source ~/.bashrc`
2. 检查 `.bashrc` 文件是否被正确修改
3. 查看终端是否有错误信息

### 如果需要恢复
1. 找到备份文件（格式：`~/.bashrc.backup.YYYYMMDD_HHMMSS`）
2. 将备份文件复制回 `.bashrc`
3. 运行 `source ~/.bashrc` 使配置生效

## 示例输出

```
[INFO] 开始bashrc配置注入...
[INFO] 用户主目录: /home/username
[INFO] bashrc文件: /home/username/.bashrc
[SUCCESS] 已备份bashrc文件到: /home/username/.bashrc.backup.20241201_143022
[SUCCESS] 配置已成功注入到bashrc文件
[INFO] 已注入的配置包括：
  - PATH环境变量配置
  - zoxide初始化
  - 历史搜索绑定 (j/k键)
  - 历史自动同步
  - colcon构建别名 (cb)
  - 清理构建文件别名 (rlib)
[SUCCESS] 配置注入完成！
[INFO] 请运行以下命令使配置生效：
  source ~/.bashrc
  或者重新打开终端
``` 