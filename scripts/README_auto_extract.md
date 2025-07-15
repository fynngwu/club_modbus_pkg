# 自动解压脚本使用说明

## 功能简介

`auto_extract.sh` 是一个智能的自动解压脚本，能够根据文件的后缀名自动识别压缩格式，并使用正确的命令进行解压。

## 全局使用设置

脚本已经配置为全局可用，你可以使用短命令 `extract` 在任何目录下使用：

```bash
# 在任何目录下都可以使用
extract <压缩文件路径>

# 示例
extract archive.zip
extract data.tar.gz
extract backup.7z
```

## 支持的压缩格式

- **ZIP**: `.zip`
- **TAR**: `.tar`
- **GZIP**: `.tar.gz`, `.tgz`, `.gz`
- **BZIP2**: `.tar.bz2`, `.tbz2`, `.bz2`
- **XZ**: `.tar.xz`, `.txz`, `.xz`
- **LZMA**: `.tar.lzma`, `.tar.lz`, `.lzma`, `.lz`
- **RAR**: `.rar`
- **7-Zip**: `.7z`

## 使用方法

### 基本用法
```bash
# 使用短命令（推荐）
extract <压缩文件路径>

# 或使用完整路径
./auto_extract.sh <压缩文件路径>
```

### 示例
```bash
# 解压 ZIP 文件
extract archive.zip

# 解压 TAR.GZ 文件
extract data.tar.gz

# 解压 7Z 文件
extract backup.7z

# 解压 RAR 文件
extract documents.rar

# 在任何目录下使用
cd /path/to/some/directory
extract /path/to/archive.zip
```

### 查看帮助
```bash
extract -h
# 或
extract --help
```

## 特性

1. **自动格式识别**: 根据文件后缀名自动选择正确的解压命令
2. **智能目录创建**: 自动创建以文件名命名的解压目录
3. **错误处理**: 检查文件是否存在和必要的解压工具是否已安装
4. **彩色输出**: 使用颜色区分不同类型的信息
5. **详细反馈**: 显示解压进度和结果
6. **全局可用**: 在任何目录下都可以使用 `extract` 命令

## 解压行为

- 脚本会在压缩文件所在的目录下创建一个以文件名命名的文件夹
- 所有文件都会解压到这个文件夹中
- 解压完成后会显示文件夹中的内容

## 依赖要求

脚本会自动检查以下工具是否已安装：
- `unzip` - 用于解压 ZIP 文件
- `tar` - 用于解压 TAR 相关格式
- `unrar` - 用于解压 RAR 文件
- `7z` - 用于解压 7Z 文件
- `gunzip`, `bunzip2`, `unxz`, `unlzma` - 用于解压各种压缩格式

如果缺少某个工具，脚本会提示安装命令。

## 安装依赖

在 Ubuntu/Debian 系统上：
```bash
sudo apt-get update
sudo apt-get install unzip unrar p7zip-full
```

在 CentOS/RHEL 系统上：
```bash
sudo yum install unzip unrar p7zip
```

## 注意事项

1. 脚本已经配置为全局可用，使用 `extract` 命令即可
2. 对于大文件，解压可能需要一些时间
3. 如果目标目录已存在，脚本会使用现有目录
4. 脚本会保持原始压缩文件不变

## 故障排除

### 常见问题

1. **命令未找到**: 如果 `extract` 命令不可用，请重新打开终端或运行 `source ~/.bashrc`
2. **工具未安装**: 按照提示安装相应的解压工具
3. **文件不存在**: 检查文件路径是否正确
4. **磁盘空间不足**: 确保有足够的磁盘空间进行解压

### 调试模式

如果需要查看详细的解压过程，可以修改脚本中的静默参数：
- 将 `unzip -q` 改为 `unzip`
- 将 `tar -xf` 改为 `tar -xvf`

## 技术细节

脚本通过以下方式实现全局可用：
1. **别名设置**: 在 `~/.bashrc` 中添加了 `alias extract="/home/wufy/Documents/CSAPP/auto_extract.sh"`
2. **系统链接**: 在 `/usr/local/bin/` 创建了符号链接，使 `extract` 命令在系统 PATH 中可用

这样设置后，你可以在任何目录下使用 `extract` 命令来解压文件。 