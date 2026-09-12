#!/bin/bash
set -e

echo "🚀 Начинаем восстановление настроек терминала..."

# 1. Установка dconf-cli (если не установлен)
if ! command -v dconf &> /dev/null; then
    echo "📦 Установка dconf-cli..."
    sudo apt update && sudo apt install -y dconf-cli
fi

# 2. Восстановление профилей, тем и цветов GNOME Terminal
if [ -f "gnome-terminal-backup.dconf" ]; then
    echo "🎨 Применяем темы и профили терминала..."
    dconf load /org/gnome/terminal/ < gnome-terminal-backup.dconf
fi

# 3. Восстановление шрифтов
if [ -d "./fonts" ] && [ "$(ls -A ./fonts)" ]; then
    echo "🔤 Устанавливаем шрифты..."
    mkdir -p ~/.local/share/fonts
    cp -r ./fonts/* ~/.local/share/fonts/
    fc-cache -f -v
fi

# 4. Восстановление .bashrc (с сохранением старого в .bak)
if [ -f "./bashrc" ]; then
    echo "⚙️ Обновляем ~/.bashrc..."
    [ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak
    cp ./bashrc ~/.bashrc
fi

[ -f "./bash_aliases" ] && cp ./bash_aliases ~/.bash_aliases

echo "✅ Всё готово! Перезапустите терминал или выполните: source ~/.bashrc"
