#!/usr/bin/env bash
# Shared helpers for the Bazzite Xbox context-menu toolkit.
set -Eeuo pipefail

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }
require_file() { [[ -f "$1" ]] || fail "File not found: $1"; }
require_dir() { [[ -d "$1" ]] || fail "Directory not found: $1"; }
find_xdvdfs() {
  if [[ -n "${XDVDFS_BIN:-}" ]]; then
    [[ -x "$XDVDFS_BIN" ]] || fail "XDVDFS_BIN is not executable: $XDVDFS_BIN"
    printf '%s\n' "$XDVDFS_BIN"
  elif command -v xdvdfs >/dev/null 2>&1; then
    command -v xdvdfs
  elif [[ -x "$HOME/.local/bin/xdvdfs" ]]; then
    printf '%s\n' "$HOME/.local/bin/xdvdfs"
  else
    fail 'xdvdfs not found. Install the Linux xdvdfs CLI and ensure it is in PATH (or set XDVDFS_BIN).'
  fi
}
find_7zip() {
  local cmd
  for cmd in 7zz 7z 7za; do
    if command -v "$cmd" >/dev/null 2>&1; then command -v "$cmd"; return; fi
  done
  fail '7-Zip CLI not found (7zz, 7z, or 7za). Install 7zip.'
}
# Refuse to overwrite or traverse symlink targets.
check_destination() { [[ ! -e "$1" && ! -L "$1" ]] || fail "Output already exists: $1"; }
make_stage() {
  local parent="$1"
  stage="$(mktemp -d -- "$parent/.xbox-toolkit-XXXXXXXX")" || fail 'Could not create staging folder.'
  trap 'if [[ -n "${stage:-}" && -d "$stage" ]]; then rm -rf -- "$stage"; fi' EXIT
}
# Find an unambiguous game root, allowing wrapper directories and sidecar files.
find_game_root() {
  local base="$1" xbe parent
  local -a roots=()
  while IFS= read -r -d '' xbe; do
    parent="$(dirname -- "$xbe")"
    roots+=("$parent")
  done < <(find "$base" -type f -iname 'default.xbe' -print0)
  [[ "${#roots[@]}" -gt 0 ]] || fail 'No default.xbe found in extracted archive.'
  [[ "${#roots[@]}" -eq 1 ]] || fail "Found ${#roots[@]} default.xbe files; ambiguous game root. Extract manually."
  printf '%s\n' "${roots[0]}"
}
# XDVDFS ls defaults to image root. Check root-level game entry, not nested paths.
image_has_root_xbe() {
  local cli="$1" iso="$2" result
  result="$("$cli" ls "$iso" 2>&1)" || return 1
  grep -Eiq '(^|[[:space:]])default\.xbe([[:space:]]|$)' <<< "$result"
}
