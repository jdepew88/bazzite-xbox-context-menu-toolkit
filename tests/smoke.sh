#!/usr/bin/env bash
set -Eeuo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
testdir="$(mktemp -d)"
trap 'rm -rf -- "$testdir"' EXIT
mkdir -p "$testdir/mockbin" "$testdir/Original Xbox Game" "$testdir/work" "$testdir/home"
printf game > "$testdir/Original Xbox Game/default.xbe"
cat > "$testdir/mockbin/xdvdfs" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
pack) printf 'mockimage' > "$3";;
ls) echo 'default.xbe';;
unpack) mkdir -p "$3"; printf xex > "$3/default.xex";;
*) exit 3;;
esac
MOCK
cat > "$testdir/mockbin/7zz" <<'MOCK'
#!/usr/bin/env bash
for arg in "$@"; do if [[ "$arg" == -o* ]]; then folder="${arg#-o}"; fi; done
mkdir -p "$folder/Wrapper"; echo foo > "$folder/Wrapper/default.xbe"
MOCK
chmod +x "$testdir/mockbin/"*
export PATH="$testdir/mockbin:$PATH" HOME="$testdir/home"
"$repo/bin/make-xbox-iso" "$testdir/Original Xbox Game"
test -s "$testdir/Original Xbox Game.iso"
if "$repo/bin/make-xbox-iso" "$testdir/Original Xbox Game"; then echo 'overwrite guard failed'; exit 1; fi
printf archive > "$testdir/work/Archive [!].7z"
"$repo/bin/extract-and-make-xbox-iso" "$testdir/work/Archive [!].7z"
test -s "$testdir/work/Archive [!].iso"
printf iso > "$testdir/work/360 Game.iso"
"$repo/bin/extract-xbox360-iso" "$testdir/work/360 Game.iso"
test -s "$testdir/work/360 Game/default.xex"
if "$repo/bin/extract-xbox360-iso" "$testdir/work/360 Game.iso"; then echo 'overwrite guard failed'; exit 1; fi
# Install/uninstall in isolated HOME.
bash "$repo/install.sh"
test -x "$HOME/.local/lib/bazzite-xbox-context-menu-toolkit/bin/make-xbox-iso"
test -x "$HOME/.local/share/kio/servicemenus/bazzite-xbox-folder.desktop"
bash "$repo/uninstall.sh"
test ! -e "$HOME/.local/share/kio/servicemenus/bazzite-xbox-folder.desktop"
test ! -e "$HOME/.local/lib/bazzite-xbox-context-menu-toolkit"
if find "$testdir" -name '.xbox-toolkit-*' | grep -q .; then echo 'staging cleanup failed'; exit 1; fi
echo 'SMOKE TESTS PASSED'
