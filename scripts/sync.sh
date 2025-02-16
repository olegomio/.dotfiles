#!/bin/zsh

echo "🔄 Neuladen der Konfiguration nach Git-Branch-Wechsel..."

# 1️⃣ Tmux neu laden (falls aktiv)
if pgrep tmux > /dev/null; then
    echo "🔄 Neuladen der tmux-Konfiguration..."
    tmux source-file ~/.tmux.conf
fi

# 2️⃣ i3 neustarten (falls aktiv)
if pgrep i3 > /dev/null; then
    echo "🔄 Neustart von i3..."
    i3-msg restart
fi

# 3️⃣ Zsh neu laden (falls aktiv)
if [[ $SHELL == */zsh ]]; then
    echo "🔄 Neuladen der zsh-Konfiguration..."
    source ~/.zshrc
fi

# 4️⃣ Neuladen von Vim/Neovim 
if pgrep nvim > /dev/null; then
    echo "🔄 Neuladen von Neovim..."
    nvim --cmd 'source $MYVIMRC' +qall
elif pgrep vim > /dev/null; then
    echo "🔄 Neuladen von Vim..."
    vim --cmd 'source $MYVIMRC' +qall
fi

echo "✅ Alle relevanten Programme wurden neu gestartet!"

