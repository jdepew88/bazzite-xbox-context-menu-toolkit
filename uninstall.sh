#!/usr/bin/env bash
set -Eeuo pipefail
app="$HOME/.local/lib/bazzite-xbox-context-menu-toolkit"
menu="$HOME/.local/share/kio/servicemenus"
for name in bazzite-xbox-folder.desktop bazzite-xbox-archive.desktop bazzite-xbox360-iso.desktop; do
  rm -f -- "$menu/$name"
done
# Only the application's dedicated install directory is removed; games and dependencies are untouched.
if [[ -d "$app" ]]; then rm -rf -- "$app"; fi
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true
printf 'Uninstalled Dolphin menus and toolkit scripts. Games and xdvdfs preserved.\n'
