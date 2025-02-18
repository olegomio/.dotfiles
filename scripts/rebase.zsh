#!/bin/zsh
set -euo pipefail

# Sicherstellen, dass wir vom master ausgehen
echo "Wechsle zu master und aktualisiere..."
git checkout master && git pull

# Liste der Branches, die rebased werden sollen
branches=(sys1 sys2)

for branch in "${branches[@]}"; do
  echo "======================================"
  echo "Verarbeite Branch: $branch"
  git checkout "$branch" || { echo "Branch $branch existiert nicht!"; exit 1; }
  echo "Hole neueste Änderungen für $branch..."
  git pull
  echo "Rebase von $branch auf master..."
  git rebase master
  echo "Hole nach Rebase nochmal die Änderungen für $branch..."
  git pull
done

echo "======================================"
echo "Rebase-Vorgang abgeschlossen für: ${branches[*]}"
