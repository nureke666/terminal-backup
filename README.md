# ДЛЯ УСТАНОВКИ
```bash
git clone https://github.com/nureke666/terminal-backup.git
cd terminal-backup
./install.sh
```

# ЕСЛИ НАДО ОБНОВИТЬ БЭКАП
```bash
cd ~/terminal-backup
dconf dump /org/gnome/terminal/ > gnome-terminal-backup.dconf && cp ~/.bashrc ./bashrc
git commit -am "Update terminal config" && git push
```
