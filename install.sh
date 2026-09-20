#!/bin/bash
set -e

# Работаем относительно папки самого скрипта, а не текущего каталога
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

NERD_FONTS_VERSION="v3.5.1"
# Профиль "Tokyo Night Dark" — ставится дефолтным
DEFAULT_PROFILE="76d93276-1d73-4d69-b111-5a1108b2cd38"
FONT_DIR="$HOME/.local/share/fonts"

# Копирует файл в $HOME, сохраняя старую версию как .bak
backup_and_copy() {
    local src="$1" dst="$2"
    [ -f "$src" ] || return 0
    echo "⚙️  Обновляем $dst..."
    [ -f "$dst" ] && cp "$dst" "$dst.bak"
    cp "$src" "$dst"
}

echo "🚀 Начинаем восстановление настроек терминала..."

# 1. Пакеты из репозиториев Ubuntu
#    Первая строка — прикладной софт, вторая — то, что нужно самому скрипту.
APT_PACKAGES=(
    curl htop tmux vim vlc neofetch gnome-shell-extension-manager
    dconf-cli wl-clipboard fontconfig unzip
)
echo "📦 Устанавливаем пакеты из apt..."
sudo apt update && sudo apt install -y "${APT_PACKAGES[@]}"

# 2. Восстановление профилей, тем и цветов GNOME Terminal
if [ -f "gnome-terminal-backup.dconf" ]; then
    echo "🎨 Применяем темы и профили терминала..."
    dconf load /org/gnome/terminal/ < gnome-terminal-backup.dconf
    echo "⭐ Ставим 'Tokyo Night Dark' профилем по умолчанию..."
    dconf write /org/gnome/terminal/legacy/profiles:/default "'$DEFAULT_PROFILE'"
fi

# 3. Настройки GNOME: тема, раскладки, горячие клавиши
echo "🎨 Настраиваем оформление GNOME..."
# Тёмная тема с фиолетовым акцентом (в GNOME 46 акцент задаётся вариантом Yaru)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme    'Yaru-purple-dark'
gsettings set org.gnome.desktop.interface icon-theme   'Yaru-purple'

echo "⌨️  Добавляем русскую раскладку..."
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

echo "⌨️  Прописываем горячие клавиши..."
gsettings set org.gnome.desktop.wm.keybindings show-desktop          "['<Super>z']"
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu  "['<Super>q']"

# 4. Расширения GNOME Shell (в apt их нет — тянем с extensions.gnome.org)
SHELL_VERSION="$(gnome-shell --version | grep -oP '\d+' | head -1)"
EXTENSIONS=(
    blur-my-shell@aunetx
    caffeine@patapon.info
    clipboard-history@alexsaveau.dev
    dash-to-panel@jderose9.github.com
)

# Свежераспакованное расширение shell ещё не видит, поэтому при неудаче
# дописываем UUID прямо в dconf — включится после перезахода в сессию.
enable_extension() {
    local uuid="$1" current
    if gnome-extensions enable "$uuid" 2> /dev/null; then
        return 0
    fi
    current="$(gsettings get org.gnome.shell enabled-extensions)"
    case "$current" in
        *"'$uuid'"*) return 0 ;;
        "@as []"|"[]") gsettings set org.gnome.shell enabled-extensions "['$uuid']" ;;
        *)             gsettings set org.gnome.shell enabled-extensions "${current%]}, '$uuid']" ;;
    esac
}

echo "🧩 Устанавливаем расширения GNOME Shell..."
for uuid in "${EXTENSIONS[@]}"; do
    if [ -d "$HOME/.local/share/gnome-shell/extensions/$uuid" ]; then
        echo "   $uuid — уже стоит"
        enable_extension "$uuid"
        continue
    fi
    url="$(curl -fsL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$SHELL_VERSION" \
        | grep -oP '"download_url": *"\K[^"]+')"
    if [ -z "$url" ]; then
        echo "   ⚠️  $uuid — нет версии под GNOME $SHELL_VERSION, пропускаем"
        continue
    fi
    ext_zip="$(mktemp -d)/$uuid.zip"
    if curl -fsL -o "$ext_zip" "https://extensions.gnome.org$url" \
        && gnome-extensions install --force "$ext_zip"
    then
        enable_extension "$uuid"
        echo "   ✓ $uuid"
    else
        echo "   ⚠️  $uuid — не установилось, пропускаем"
    fi
    rm -rf "$(dirname "$ext_zip")"
done

# Настройки расширений (как они выкручены на основной машине)
if [ -f "gnome-shell-extensions.dconf" ]; then
    echo "⚙️  Применяем настройки расширений..."
    dconf load /org/gnome/shell/extensions/ < gnome-shell-extensions.dconf
fi

# 5. Шрифты: берём локальные .ttf, если они есть, иначе качаем Nerd Font
echo "🔤 Устанавливаем шрифты..."
mkdir -p "$FONT_DIR"
if compgen -G "./fonts/*.ttf" > /dev/null; then
    cp ./fonts/*.ttf "$FONT_DIR/"
elif compgen -G "$FONT_DIR/JetBrainsMonoNerdFont*.ttf" > /dev/null; then
    echo "   JetBrains Mono Nerd Font уже установлен, пропускаем"
else
    echo "⬇️  Качаем JetBrains Mono Nerd Font ($NERD_FONTS_VERSION)..."
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    curl -fL --progress-bar -o "$TMP_DIR/JetBrainsMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/JetBrainsMono.zip"
    unzip -oq "$TMP_DIR/JetBrainsMono.zip" '*.ttf' -d "$TMP_DIR/ttf"
    cp "$TMP_DIR"/ttf/*.ttf "$FONT_DIR/"
fi
fc-cache -f > /dev/null

# 6. Восстановление конфигов шелла (старые версии сохраняются в .bak)
backup_and_copy ./bashrc       "$HOME/.bashrc"
backup_and_copy ./profile      "$HOME/.profile"
backup_and_copy ./bash_aliases "$HOME/.bash_aliases"

echo ""
echo "✅ Всё готово! Перезапустите терминал или выполните: source ~/.bashrc"
echo "   Расширения GNOME заработают после перезахода в сессию (logout/login)."
echo ""
echo "📋 Это скрипт не ставит — качаем руками:"
echo "   • Google Chrome    — https://www.google.com/chrome/"
echo "   • Discord          — https://discord.com/download"
echo "   • Telegram         — https://desktop.telegram.org/"
echo "   • Obsidian         — https://obsidian.md/download"
echo "   • VS Code          — https://code.visualstudio.com/download"
echo "   • Antigravity CLI  — установщик кладёт бинарь в ~/.local/bin"
echo "   • Claude Code      — https://claude.com/product/claude-code"
echo "   • Claude Desktop   — https://claude.ai/download"
echo ""
