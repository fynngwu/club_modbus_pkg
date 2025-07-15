# 解压 LINUX.tar.gz 并配置TTY端口访问权限

## 1. 解压 LINUX.tar.gz

在终端中执行以下命令：

```bash
tar -xzvf LINUX.tar.gz
```

这会将压缩包内容解压到当前目录。

---

## 2. 配置用户无需sudo访问TTY端口

Linux下，tty端口（如`/dev/ttyUSB0`、`/dev/ttyS0`等）通常属于`dialout`或`tty`用户组。你可以通过以下步骤让当前用户无需sudo即可访问这些端口：

### 步骤一：查看TTY端口所属用户组

插入你的串口设备后，运行：

```bash
ls -l /dev/ttyUSB* /dev/ttyS*
```

输出类似：

```
crw-rw---- 1 root dialout 188, 0  6月  1 10:00 /dev/ttyUSB0
```

可以看到设备属于`dialout`组。

### 步骤二：将当前用户加入对应用户组

假设是`dialout`组，执行：

```bash
sudo usermod -aG dialout $USER
```

如果是`tty`组，则：

```bash
sudo usermod -aG tty $USER
```

### 步骤三：重新登录

执行完上述命令后，**需要重新登录或重启电脑**，让组权限生效。

### 步骤四：验证权限

重新登录后，运行：

```bash
groups
```

确认输出中包含`dialout`或`tty`。

此时即可无需sudo访问tty端口。

---

如有疑问可参考发行版官方文档或联系管理员。 