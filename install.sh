#!/usr/bin/env bash
set -Eeuo pipefail
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
app="$HOME/.local/lib/bazzite-xbox-context-menu-toolkit"
menu="$HOME/.local/share/kio/servicemenus"
mkdir -p -- "$app/bin" "$menu"
for file in "$source_dir"/bin/*; do install -m 755 -- "$file" "$app/bin/$(basename -- "$file")"; done
for file in "$source_dir"/servicemenus/*.desktop; do install -m 755 -- "$file" "$menu/$(basename -- "$file")"; done
printf 'Installed Dolphin service menus and scripts.\n'
if ! command -v xdvdfs >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/xdvdfs" ]]; then
  echo 'WARNING: xdvdfs not found. Install upstream xdvdfs CLI before use.' >&2
fi
if ! command -v 7zz >/dev/null 2>&1 && ! command -v 7z >/dev/null 2>&1 && ! command -v 7za >/dev/null 2>&1; then
  echo 'WARNING: 7-Zip CLI not found. Required for archive conversion.' >&2
fi
if ! command -v konsole >/dev/null 2>&1; then echo 'WARNING: Konsole not found; commands will run without a held terminal.' >&2; fi
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true
printf 'Restart Dolphin if menu actions are not immediately visible.\n'
