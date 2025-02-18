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
