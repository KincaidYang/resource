#!/bin/bash

set -e

# 定义日志路径
LOG_PATH="/var/log"

# 清理系统日志文件
find $LOG_PATH -type f -name "*.log" -exec truncate -s 0 {} \;

# 清理特定日志文件
truncate -s 0 /var/log/syslog 2>/dev/null
truncate -s 0 /var/log/auth.log 2>/dev/null
truncate -s 0 /var/log/kern.log 2>/dev/null
truncate -s 0 /var/log/dmesg 2>/dev/null
truncate -s 0 /var/log/messages 2>/dev/null

# 清理 journalctl 日志
journalctl --vacuum-size=100M 2>/dev/null
journalctl --vacuum-time=7d 2>/dev/null

# 清理临时文件
rm -rf /tmp/* /var/tmp/*

# 删除 TAT 日志
rm -rf /tmp/tat_agent/
if [ -f /usr/local/qcloud/tat_agent/log/tat_agent.log ]; then
    echo '' > /usr/local/qcloud/tat_agent/log/tat_agent.log
fi

# 清理LH用户操作历史
echo -n "" > /home/lighthouse/.bash_history

# Load OS release information
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "OS release information is missing."
    exit 1
fi

echo "$ID"

# Define actions based on OS ID
case $ID in
    centos)
        # CentOS specific commands
        yum clean all
        rm -f ~root/.ssh/authorized_keys
        echo '' > ~root/.bash_history
        passwd -d root
        ;;
    ubuntu)
        # Ubuntu specific commands
        sudo apt clean
        sudo rm -f ~root/.ssh/authorized_keys
        echo '' | sudo tee ~root/.bash_history > /dev/null
        passwd -d ubuntu
        ;;
    opencloudos)
        # OpenCloudOS specific commands
        yum clean all
        rm -f ~root/.ssh/authorized_keys
        echo '' > ~root/.bash_history
        passwd -d root
        ;;
    *)
        # Unknown OS
        echo "Unknown Linux distribution: $ID"
        exit 1
        ;;
esac

# 删除脚本自身
echo "deleting script: $0"
rm -- "$0"