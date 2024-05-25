#!/bin/bash

# Обновление системы и установка shadowsocks-libev
sudo apt update && sudo apt upgrade -y
sudo apt install shadowsocks-libev -y

# Функция для запроса у пользователя ввода и проверки, что ввод не пустой
ask_for_input() {
    local prompt="$1"
    local var
    while true; do
        read -rp "$prompt: " var
        if [ -n "$var" ]; then
            echo "$var"
            return
        else
            echo "Ввод не может быть пустым. Пожалуйста, попробуйте еще раз."
        fi
    done
}

# Запрос значений у пользователя
server_ip=$(ask_for_input "Введите Server IP")
server_port=$(ask_for_input "Введите Server Port")
password=$(ask_for_input "Введите Password")
encryption_method=$(ask_for_input "Введите Encryption Method")

# Создание JSON-конфигурации
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

# Запись конфигурации в файл
config_path="/etc/shadowsocks-libev/config.json"
echo "$config_json" | sudo tee "$config_path" > /dev/null

# Запуск и включение службы Shadowsocks-libev
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# Настройка брандмауэра
sudo ufw allow $server_port/tcp
sudo ufw allow $server_port/udp
sudo ufw allow 22/tcp
sudo ufw allow 22/udp
sudo ufw --force enable

# Перезапуск службы Shadowsocks-libev
sudo systemctl restart shadowsocks-libev

echo "complite"
