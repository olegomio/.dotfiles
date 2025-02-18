#!/bin/zsh
set -euo pipefail

# Speichere den aktuellen Branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Aktueller Branch: $current_branch"

# Arbeite mit master
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
  echo "Push nach Rebase"
  git push
done

# Wechsle zurück zum ursprünglichen Branch
echo "======================================"
echo "Wechsle zurück zum ursprünglichen Branch: $current_branch"
git checkout "$current_branch"

echo "Rebase-Vorgang abgeschlossen für: ${branches[*]}"
