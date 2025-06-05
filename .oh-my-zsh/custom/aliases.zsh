alias ret-de='sudo killall --interactive --signal SIGINT openconnect; sleep 1; sudo openconnect --protocol=gp vpnaccess-de.retarus.com --certificate=/home/alexanderg/Documents/certificate.crt --sslkey=/home/alexanderg/Documents/private.key --user=alexanderg --quiet --background --pid-file=/run/openconnect.pid --mtu=1400 --base-mtu=1500 --servercert pin-sha256:cB0+M/bos7xbgP4tG0k1JIKGHRV02XjQz3dgXMaLTk8='

alias ret-us='sudo killall --interactive --signal SIGINT openconnect; sleep 1; sudo openconnect --protocol=gp vpnaccess-us.retarus.com --certificate=/home/alexanderg/Documents/certificate.crt --sslkey=/home/alexanderg/Documents/private.key --user=alexanderg --quiet --background --pid-file=/run/openconnect.pid --mtu=1400 --base-mtu=1500 --servercert pin-sha256:cB0+M/bos7xbgP4tG0k1JIKGHRV02XjQz3dgXMaLTk8='
 

alias disc-gp='sudo killall --signal SIGINT openconnect'
alias list-gp='sudo ps -aux | grep openconnect | grep -v grep'

# Headset dongle reset
alias hs='systemctl --user restart wireplumber; systemctl --user restart pipewire'

lnsp() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: lnsp <Pfad zur eigentlichen Datei> <Pfad zum Symlink>"
    return 1
  fi

  local source_file="$1"
  local symlink="$2"

  # Erstelle alle nötigen Ordner für die Quelldatei
  local source_dir
  source_dir=$(dirname "$source_file")
  if ! mkdir -p "$source_dir"; then
    echo "Fehler: Verzeichnis $source_dir konnte nicht erstellt werden."
    return 1
  fi

  # Falls die Quelldatei nicht existiert, erstelle sie
  if [ ! -e "$source_file" ]; then
    if ! touch "$source_file"; then
      echo "Fehler: Datei $source_file konnte nicht erstellt werden."
      return 1
    fi
  fi

  # Erstelle den Ordner für den Symlink
  local link_dir
  link_dir=$(dirname "$symlink")
  if ! mkdir -p "$link_dir"; then
    echo "Fehler: Zielverzeichnis $link_dir konnte nicht erstellt werden."
    return 1
  fi

  # Lege den symbolischen Link an
  if ! ln -s "$source_file" "$symlink"; then
    echo "Fehler: Symbolischer Link konnte nicht erstellt werden."
    return 1
  fi

  echo "Symbolischer Link erstellt: $symlink -> $source_file"
}
