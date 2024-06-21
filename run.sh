#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install shadowsocks-libev -y

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
echo "$config_json" | sudo tee "$config_path" > /dev/null

sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

sudo apt install ufw
sudo ufw allow $server_port/tcp
sudo ufw allow $server_port/udp
sudo ufw allow 22/tcp
sudo ufw allow 22/udp
sudo ufw --force enable

sudo systemctl restart shadowsocks-libev

echo "complite"
