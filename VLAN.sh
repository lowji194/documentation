#!/bin/bash

Eth=$(ip addr show | grep -E '^2:' | sed 's/^[0-9]*: \(.*\):.*/\1/')
IP4=$(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | sort -t '.' -k 4,4nr | head -n 1)
while true; do
    IP6=$(curl -6 -s icanhazip.com | cut -f1-4 -d':')
    if [ -n "$IP6" ]; then
        echo "IPv6 address obtained: $IP6"
        break
    else
        echo "No IPv6 address found. Retrying..."
    fi
    sleep 1
done

WORKDIR="/home/Lowji194"
WORKDATA="${WORKDIR}/data.txt"
BOOT_IP_SCRIPT="${WORKDIR}/boot_ip.sh"
USER_PROXY_CFG="/usr/local/etc/LowjiConfig/UserProxy.cfg"
IP6_FILE="${WORKDIR}/ip6.txt"

# Lấy IP hiện tại trong ip6.txt (nếu tồn tại)
OLD_IP6=""
if [ -f "$IP6_FILE" ]; then
    OLD_IP6=$(cat "$IP6_FILE")
fi

# Kiểm tra và cập nhật IP trong ip6.txt nếu IP đã thay đổi
if [ "$IP6" != "$OLD_IP6" ]; then
    echo "$IP6" > "$IP6_FILE"
    echo "Rotate IP Success"

    # Danh sách file cần sửa đổi
    FILES=("$WORKDATA" "$BOOT_IP_SCRIPT" "$USER_PROXY_CFG")

    # Sửa nội dung trong các file
    for FILE in "${FILES[@]}"; do
        if [ -f "$FILE" ]; then
            # Thay thế giá trị IP cũ thành IP mới ($IP6)
            if [ -n "$OLD_IP6" ]; then
                sed -i "s|$OLD_IP6|$IP6|g" "$FILE"
            fi
        fi
    done
fi
