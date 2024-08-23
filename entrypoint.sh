#!/bin/bash

ask_for_input() {
    local prompt="$1"
    local default_value="$2"
    local var
    while true; do
        if [ -n "$default_value" ]; then
            read -rp "$prompt [$default_value]: " var
            var="${var:-$default_value}"
        else
            read -rp "$prompt: " var
        fi

        if [ -n "$var" ]; then
            echo "$var"
            return
        else
            echo "invalid input"
        fi
    done
}

server_ip=$(ask_for_input "input Server IP")
server_port=$(ask_for_input "input Server Port" "8388")
password=$(ask_for_input "input your Password")
encryption_method=$(ask_for_input "Encryption Method" "aes-256-cfb")

config_json=$(cat <<EOF
{
    "server":"$server_ip",
    "server_port":$server_port,
    "password":"$password",
    "timeout":300,
    "method":"$encryption_method",
    "fast_open": false
}
EOF
)

config_path="/etc/shadowsocks-libev/config.json"
echo "$config_json" | tee "$config_path" > /dev/null

# Start Shadowsocks
systemctl start shadowsocks-libev
systemctl enable shadowsocks-libev

# Configure UFW
ufw allow $server_port/tcp
ufw allow $server_port/udp
ufw allow 22/tcp
ufw allow 22/udp
ufw --force enable

# Restart Shadowsocks to apply settings
systemctl restart shadowsocks-libev

echo "Complete"