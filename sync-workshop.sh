#!/bin/sh
# Stage this mod into ~/Zomboid/Workshop for the in-game uploader.
# ~/Zomboid/mods/HalfSmoked is the source of truth; run this before publishing.
set -e
SRC="$HOME/Zomboid/mods/HalfSmoked"
DST="$HOME/Zomboid/Workshop/HalfSmoked/Contents/mods/HalfSmoked"
mkdir -p "$DST"
rsync -a --delete --delete-excluded \
  --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' \
  --exclude='README.md' --exclude='sync-workshop.sh' \
  "$SRC/" "$DST/"
echo "synced -> $DST"
