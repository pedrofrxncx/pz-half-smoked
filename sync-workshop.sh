#!/bin/sh
# Stage this mod into ~/Zomboid/Workshop for the in-game uploader.
#
# The staging copy shares id=HalfSmoked with ~/Zomboid/mods/HalfSmoked, and PZ
# scans both trees -- so while it exists it SHADOWS the one you are editing.
# Stage right before uploading, then run "./sync-workshop.sh clean".
set -e
SRC="$HOME/Zomboid/mods/HalfSmoked"
DST="$HOME/Zomboid/Workshop/HalfSmoked/Contents/mods/HalfSmoked"

if [ "$1" = "clean" ]; then
    rm -rf "$HOME/Zomboid/Workshop/HalfSmoked/Contents"
    echo "unstaged -- ~/Zomboid/mods/HalfSmoked is live again"
    exit 0
fi

mkdir -p "$DST"
rsync -a --delete --delete-excluded \
  --exclude='.git' --exclude='.gitignore' --exclude='.DS_Store' \
  --exclude='README.md' --exclude='sync-workshop.sh' \
  --exclude='workshop-description.txt' \
  "$SRC/" "$DST/"
echo "staged -> $DST"
echo "after uploading, run: ./sync-workshop.sh clean"
