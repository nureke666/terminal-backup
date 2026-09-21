# Terminal backup

Бэкап настроек рабочего окружения Ubuntu: профили и темы GNOME Terminal, горячие клавиши GNOME,
расширения GNOME Shell с их настройками, `~/.bashrc`, `~/.profile` и шрифт JetBrains Mono Nerd Font.

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
* включает тёмную тему с фиолетовым акцентом (`Yaru-purple-dark`) и добавляет русскую раскладку
  рядом с английской;
* накатывает горячие клавиши из `keybindings.dconf` (см. список ниже);
* ставит расширения GNOME Shell — Blur my Shell, Caffeine, Clipboard History, Dash to Panel —
  и накатывает их настройки (заработают после перезахода в сессию);
* скачивает и ставит шрифт JetBrains Mono Nerd Font;
* раскладывает `bashrc` и `profile` по `$HOME`, сохраняя старые версии как `.bak`.

Всё, что уже установлено, пропускается — скрипт можно запускать повторно.
`git` в список не входит: он и так нужен, чтобы склонировать этот репозиторий.

В конце скрипт напомнит списком, что нужно доставить руками: Chrome, Discord, Telegram,
Obsidian, VS Code, Antigravity CLI, Claude Code, Claude Desktop.

## ГОРЯЧИЕ КЛАВИШИ

Всё лежит в `keybindings.dconf` (дамп из dconf, пути внутри файла — относительно `/org/gnome/`).

| Клавиши             | Что делает                                    |
|---------------------|-----------------------------------------------|
| `Alt+W`             | развернуть окно на весь экран                 |
| `Alt+S`             | вернуть окно из развёрнутого                  |
| `Alt+F10`           | развернуть/вернуть — одной клавишей           |
| `Alt+A` / `Alt+D`   | прилепить окно к левой / правой половине      |
| `Alt+Q` / `Alt+E`   | рабочий стол левее / правее                   |
| `Super+Z`           | свернуть все окна (показать рабочий стол)     |
| `Super+Q`           | меню окна                                     |
| `Super+E`           | файловый менеджер                             |
| `Super+B`           | браузер                                       |

В терминале: `Ctrl+Shift+A` — выделить всё, `Ctrl+P` — показать/скрыть меню (из
`gnome-terminal-backup.dconf`).

## ЕСЛИ НАДО ОБНОВИТЬ БЭКАП
```bash
cd ~/Projects/terminal-backup
dconf dump /org/gnome/terminal/ > gnome-terminal-backup.dconf
dconf dump /org/gnome/shell/extensions/ > gnome-shell-extensions.dconf
# горячие клавиши: окна, тайлинг, рабочие столы, media-keys
dconf dump /org/gnome/ | awk '
  /^\[/ { keep = ($0 ~ /^\[(desktop\/wm\/keybindings|mutter\/keybindings|mutter\/wayland\/keybindings|shell\/keybindings|settings-daemon\/plugins\/media-keys)/) }
  keep
' > keybindings.dconf
cp ~/.bashrc ./bashrc
cp ~/.profile ./profile
[ -f ~/.bash_aliases ] && cp ~/.bash_aliases ./bash_aliases
git commit -am "Update terminal config" && git push
```

> `bashrc`/`profile` в репозитории слегка причёсаны под любую машину (`$HOME` вместо
> `/home/nurik`), так что после `cp` глянь `git diff` — не затёрлось ли это обратно.
