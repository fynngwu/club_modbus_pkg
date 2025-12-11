# 解压 LINUX.tar.gz 并配置TTY端口访问权限
```bash
# 在 Normal 模式下让 j/k 基于当前输入搜索历史
bind  '"\e[A": history-search-backward'
bind  '"\e[B": history-search-forward'
alias vb='vim ~/.bashrc'
alias sb='source ~/.bashrc'

cb() {
    local args=(
        --symlink-install
        --parallel-workers $(nproc)
        # --event-handlers console_direct+
        # 可选：显式启用 Ninja（通常默认已启用）
        # --cmake-args -G Ninja
        --cmake-args
        -G Ninja
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
        --continue-on-error
        # --executor sequential # 防止CPU占用太高
    )

    if [ $# -gt 0 ]; then
        args+=(--packages-up-to "$@")
    fi

    echo ">>> Running: colcon build ${args[*]}"
    colcon build "${args[@]}"
}
wget http://fishros.com/install -O fishros && . fishros

# 初始化zoxide
eval "$(zoxide init bash)"


# 自动同步history
export PROMPT_COMMAND="history -a; history -c; history -r; _zoxide_hook"

# 常用别名
alias cb='colcon build --symlink-install --parallel-workers 8'
alias cbp='colcon build --symlink-install --parallel-workers 8 --packages-select'
alias rlib='rm -rf build log install'

alias lidar='ros2 launch livox_ros_driver2 rviz_MID360_launch.py'
alias lid='ros2 launch livox_ros_driver2 msg_MID360_launch.py'
alias fastlio='ros2 launch ros2 launch fast_lio mapping.launch.py'

sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt update
sudo apt install appimagelauncher

ros2 node list | awk '{print $1}' | grep -v '^/_ros2_daemon' | xargs -r -n1 ros2 node kill

source /opt/ros/humble/setup.bash
source ~/ws_livox/install/setup.bash
source ~/ros2_ws/install/setup.bash
```

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
