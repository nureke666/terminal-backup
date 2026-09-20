# Terminal backup

Бэкап настроек рабочего окружения Ubuntu: профили и темы GNOME Terminal, расширения GNOME Shell
с их настройками, `~/.bashrc`, `~/.profile` и шрифт JetBrains Mono Nerd Font.

## ДЛЯ УСТАНОВКИ
```bash
git clone https://github.com/nureke666/terminal-backup.git
cd terminal-backup
./install.sh
```

Что делает скрипт:

* ставит софт: `curl`, `htop`, `tmux`, `vim`, `vlc`, `neofetch` (алиас `nurik`), Extension Manager
  (плюс `dconf-cli`, `wl-clipboard`, `fontconfig`, `unzip` — они нужны самому скрипту);
* применяет темы GNOME Terminal и делает **Tokyo Night Dark** профилем по умолчанию;
* включает тёмную тему с фиолетовым акцентом (`Yaru-purple-dark`), добавляет русскую раскладку
  рядом с английской и вешает горячие клавиши `Super+Z` (свернуть все окна) и `Super+Q` (меню окна);
* ставит расширения GNOME Shell — Blur my Shell, Caffeine, Clipboard History, Dash to Panel —
  и накатывает их настройки (заработают после перезахода в сессию);
* скачивает и ставит шрифт JetBrains Mono Nerd Font;
* раскладывает `bashrc` и `profile` по `$HOME`, сохраняя старые версии как `.bak`.

Всё, что уже установлено, пропускается — скрипт можно запускать повторно.
`git` в список не входит: он и так нужен, чтобы склонировать этот репозиторий.

В конце скрипт напомнит списком, что нужно доставить руками: Chrome, Discord, Telegram,
Obsidian, VS Code, Antigravity CLI, Claude Code, Claude Desktop.

## ЕСЛИ НАДО ОБНОВИТЬ БЭКАП
```bash
cd ~/Projects/terminal-backup
dconf dump /org/gnome/terminal/ > gnome-terminal-backup.dconf
dconf dump /org/gnome/shell/extensions/ > gnome-shell-extensions.dconf
cp ~/.bashrc ./bashrc
cp ~/.profile ./profile
[ -f ~/.bash_aliases ] && cp ~/.bash_aliases ./bash_aliases
git commit -am "Update terminal config" && git push
```
