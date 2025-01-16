
#!/bin/bash

# 定义主机列表、用户名和密码
HOSTS=("10.0.0.220" "10.0.0.221" "10.0.0.222" "10.0.0.223" "10.0.0.224" "10.0.0.225" "10.0.0.226") # 将目标主机 IP 添加到这里
USER="root"                          # 修改为目标主机的用户名
PASSWORD="123456"                      # 修改为目标主机的密码

# 检查是否安装了 sshpass
if ! command -v sshpass &>/dev/null; then
    echo "==> 未找到 sshpass 工具，正在安装..."
    if [ -x "$(command -v apt)" ]; then
        sudo apt update && sudo apt install sshpass -y
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install sshpass -y
    else
        echo "==> 无法自动安装 sshpass，请手动安装后重试。"
        exit 1
    fi
fi

# 1. 创建 SSH 密钥
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "==> 生成 SSH 密钥对..."
    ssh-keygen -t rsa -b 2048 -f "$HOME/.ssh/id_rsa" -N ""
else
    echo "==> SSH 密钥对已存在，跳过生成步骤。"
fi


# 2. 将公钥添加到自身的 authorized_keys（连接自身）
echo "==> 添加公钥到自身的 authorized_keys..."
cat "$HOME/.ssh/id_rsa.pub" >> "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

# 3. 分发密钥到其他主机
echo "==> 分发公钥到目标主机..."
for HOST in "${HOSTS[@]}"; do
    echo "----> 处理主机 $HOST ..."
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no -r ~/.ssh "$USER@$HOST:" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "----> 主机 $HOST 已配置免密登录。"
    else
        echo "----> 无法配置主机 $HOST，请检查连接性和权限。"
    fi
done

# 验证是否成功
echo "==> 测试免密登录是否成功..."
for HOST in "${HOSTS[@]}"; do
    ssh -o BatchMode=yes "$USER@$HOST" "echo '$HOST 无密码登录成功'" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "----> 主机 $HOST 免密登录测试成功。"
    else
        echo "----> 主机 $HOST 免密登录测试失败，请检查。"
    fi
done

echo "==> 多主机免密认证配置完成！"

