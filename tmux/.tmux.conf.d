#set -ga terminal-overrides ",screen-256color*:Tc"
#set-option -g default-terminal "screen-256color"
set -s escape-time 0

unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
set -g status-style 'bg=#333333 fg=#5eacd3'

bind r source-file ~/.tmux.conf
set -g base-index 1

set-window-option -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

# vim-like pane switching
bind -r ^ last-window
bind -r k select-pane -U
bind -r j select-pane -D
bind -r h select-pane -L
bind -r l select-pane -R

bind -r D neww -c "#{pane_current_path}" "[[ -e TODO.md ]] && nvim TODO.md || nvim ~/.dotfiles/personal/todo.md"

# forget the find window.  That is for chumps
bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

bind-key -r i run-shell "tmux neww tmux-cht.sh"
bind-key -r G run-shell "~/.local/bin/tmux-sessionizer ~/work/nrdp"
bind-key -r C run-shell "~/.local/bin/tmux-sessionizer ~/work/tvui"
bind-key -r R run-shell "~/.local/bin/tmux-sessionizer ~/work/milo"
# bind-key -r L run-shell "~/.local/bin/tmux-sessionizer ~/work/hpack"
bind-key -r H run-shell "~/.local/bin/tmux-sessionizer ~/personal/vim-with-me"
bind-key -r T run-shell "~/.local/bin/tmux-sessionizer ~/personal/refactoring.nvim"
bind-key -r N run-shell "~/.local/bin/tmux-sessionizer ~/personal/harpoon"
bind-key -r S run-shell "~/.local/bin/tmux-sessionizer ~/personal/developer-productivity"

# Setzt das Standard-Theme auf TokyoNight Farben
set -g default-terminal "tmux-256color"
set-option -g status-bg "#1a1b26"
#set-option -g status-fg "#a9b1d6"
set-option -g pane-border-style "fg=#3b4261"
set-option -g pane-active-border-style "fg=#7aa2f7"
set-option -g message-style "fg=#7aa2f7,bg=#1a1b26"
set-option -g status-left "#[fg=#7aa2f7] #S #[fg=#c0caf5]"
set-option -g status-right "#[fg=#7dcfff] %Y-%m-%d %H:%M #[fg=#7aa2f7]"

# Scrollbar-Farbe für tmux (falls du `tmux-plugins/tmux-resurrect` nutzt)
set-option -g mode-style "bg=#3b4261,fg=#c0caf5"

# Truecolor aktivieren
set-option -ga terminal-overrides ",xterm-256color:Tc"

# Cursor-Highlight anpassen
set-option -g message-command-style "bg=#3b4261,fg=#c0caf5"

