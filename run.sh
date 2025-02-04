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
            echo "Ошибка: ввод не может быть пустым."
        fi
    done
}

#  Shadowsocks cred's
server_ip=$(ask_for_input "Введите IP сервера" "0.0.0.0")
server_port=$(ask_for_input "Введите порт сервера" "8388")
password=$(ask_for_input "Введите пароль")
encryption_method=$(ask_for_input "Введите метод шифрования" "aes-256-cfb")

# SSH cust port
ssh_port=$(ask_for_input "Введите порт для SSH (по умолчанию 22)" "22")

# creatin' config Shadowsocks
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

# saving conf Shadowsocks
config_path="/etc/shadowsocks-libev/config.json"
echo "$config_json" | sudo tee "$config_path" > /dev/null

# UFW setup
sudo apt install ufw -y

# Deletion of all existing rules
sudo ufw --force reset

# necessary prots
sudo ufw allow $ssh_port/tcp comment "SSH"
sudo ufw allow $server_port/tcp comment "Shadowsocks TCP"
sudo ufw allow $server_port/udp comment "Shadowsocks UDP"

# Adding false open ports for confusion
fake_ports=(2459 2362 5624 52346 5422)
for port in "${fake_ports[@]}"; do
    sudo ufw allow $port/tcp comment "Ложный порт"
    sudo ufw allow $port/udp comment "Ложный порт"
done

sudo ufw --force enable

sudo sed -i "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo systemctl restart shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# Conclusion
echo "Установка завершена!"
echo "Порт SSH: $ssh_port"
echo "Порт Shadowsocks: $server_port"
echo "Пароль Shadowsocks: $password"
echo "Метод шифрования: $encryption_method"
echo "Ложные порты: ${fake_ports[*]}"