# Bazzite Xbox Context Menu Toolkit

Three **KDE Plasma / Dolphin** right-click actions for **Bazzite Linux**, powered by [xDVDFS](https://github.com/antangelo/xdvdfs). This project is independent of xDVDFS, xemu, Xenia, and Bazzite.

| Dolphin action | Input | Output | Target emulator |
|---|---|---|---|
| **Create Original Xbox XISO** | An unpacked game folder with `default.xbe` at its root | `Game.iso` beside the folder | [xemu](https://xemu.app/) |
| **Extract Archive and Create Original Xbox XISO** | `.7z`, `.zip`, `.rar` containing a game folder with `default.xbe` | `Game.iso` beside the archive | [xemu](https://xemu.app/) |
| **Extract Xbox 360 ISO** | A compatible Xbox 360 `.iso` | `Game/` folder with `default.xex` | [Xenia](https://github.com/xenia-project/xenia) |

**Original Xbox:** Normal game files (including `default.xbe`) are either already in a folder or inside a compressed archive. `xdvdfs pack` produces a correctly structured **XISO** image for xemu. The archive conversion locates the game directory even when it is enclosed in a wrapper folder, but refuses ambiguous archives containing multiple `default.xbe` copies.

**Xbox 360:** The game is already an Xbox 360 ISO. `xdvdfs unpack` extracts it to a directory containing `default.xex`, which can be selected in Xenia if the game and image layout are supported. This is **not** the inverse of ZIP extraction, and simply renaming ISO files does not convert their format.

## Platform and prerequisites

- **Bazzite Linux + KDE Plasma 6 + Dolphin** (initial target); other compatible KDE Plasma installations may work but are not the primary tested target.
- `bash`, `find`, `realpath`, `mktemp`, `grep`, `install` and standard GNU core utilities.
- [xDVDFS CLI](https://github.com/antangelo/xdvdfs/releases) installed as `xdvdfs` in `PATH`, or executable at `~/.local/bin/xdvdfs`. Set `XDVDFS_BIN` to an absolute executable path when running scripts directly if needed. **Use xDVDFS v0.8.2 or newer** for Xbox 360 XGD2/XGD3 handling.
- `7zz`, `7z`, or `7za` from 7-Zip for archive conversion; `7z` alone may not support every RAR variant on every installation.
- KDE **Konsole** is recommended for readable terminal progress/errors.
- Enough free space **on the source volume** for temporary extraction and output. This toolkit stages files in a hidden temporary folder beside the source, not under `/tmp`.

On Bazzite, which is image-based/immutable, choose appropriate user-space, Homebrew, or supported distro methods to install command-line dependencies. Do **not** disable immutability merely to install this toolkit. The toolkit itself installs under your home directory and does not require sudo.

## Install

1. Download the repository ZIP from **Code → Download ZIP**, or clone the repository.
2. Extract it, open Konsole inside the directory containing `install.sh`, and run:

   ```bash
   bash ./install.sh
   ```

3. Install the upstream xDVDFS Linux executable separately and confirm `xdvdfs --help` works, then verify a 7-Zip CLI command such as `7zz` (if you want compressed archive conversion).
4. Restart Dolphin if necessary. Right-click a compatible file or folder; the new action should appear under **Actions** or the service-menu section of Dolphin's context menu.

The installer copies files into:

```text
~/.local/lib/bazzite-xbox-context-menu-toolkit/bin/
~/.local/share/kio/servicemenus/
```

The installed Dolphin `.desktop` entries are marked executable, as required by current Dolphin service menu handling. No system-wide changes, root privileges, daemon, or background process.

### Optional command-line use

The same tools work without Dolphin after installation:

```bash
"$HOME/.local/lib/bazzite-xbox-context-menu-toolkit/bin/make-xbox-iso" "/path/to/Game Folder"
"$HOME/.local/lib/bazzite-xbox-context-menu-toolkit/bin/extract-and-make-xbox-iso" "/path/to/Game.7z"
"$HOME/.local/lib/bazzite-xbox-context-menu-toolkit/bin/extract-xbox360-iso" "/path/to/Game.iso"
```

The ISO outputs retain the original archive/folder stem (including region markers and spaces). An existing destination file/folder causes a safe error rather than replacement. The scripts clean up their own staging directories on normal failures and interrupts; hardware failure or forced termination may require manually deleting a leftover `.xbox-toolkit-*` folder.

## Uninstall

From the downloaded project directory:

```bash
bash ./uninstall.sh
```

This removes only this toolkit's Dolphin entries and installed scripts. It **does not delete** your games, output ISOs, `xdvdfs`, 7-Zip, Konsole, or other file-manager customizations.

## Troubleshooting

| Problem | What to check |
|---|---|
| Right-click action missing | Check Dolphin's **Actions**, restart Dolphin, and confirm executable `.desktop` files exist in `~/.local/share/kio/servicemenus/`. |
| `xdvdfs` not found | Install the upstream Linux binary; check `xdvdfs --help` or `~/.local/bin/xdvdfs`. |
| No 7-Zip command | Install `7zz` / `7z` / `7za` for archive mode. |
| Archive conversion says ambiguous root | Multiple `default.xbe` entries found; inspect and manually extract the intended folder, then use the folder menu action. |
| No `default.xex` | The image may be a special/installer disc, incomplete, or incompatible with xDVDFS. |
| Action not shown on an ISO | Dolphin uses MIME detection; check whether the file's MIME type matches `application/x-cd-image` or `application/x-iso9660-image`. |
| Output already exists | Move/rename the existing output; scripts deliberately refuse overwrites. |
| Conversion succeeds but emulator does not boot | Examine xemu/Xenia compatibility and emulator configuration. `default.xbe`/`default.xex` checks are not proof of bootability. |

**Safety/limitations:** Use only backups you are authorized to handle. The toolkit does not provide games, BIOS files, decrypted data, DRM circumvention, or emulators. Some Xbox 360 disc variants are unsupported. The folder action checks exact lowercase `default.xbe`; archive detection is case-insensitive. No automatic update mechanism is included.

## Other Linux file managers: contributions welcome

This release targets **KDE Plasma / Dolphin on Bazzite**. The underlying Bash conversion scripts are not tied to Dolphin, but the right-click integration uses KDE service menus.

**GNOME Files/Nautilus, Nemo, Thunar, and other Linux file managers could be supported in the future.** Please open an issue describing your Linux distribution, desktop environment, and file manager. Pull requests implementing integrations are welcome. Prefer adapters which invoke the existing `bin/` scripts rather than duplicating ISO logic; include installation/uninstallation instructions and tests where practical.

## Attribution and license

- [xDVDFS by antangelo](https://github.com/antangelo/xdvdfs), separately obtained and licensed under its own MIT terms. Its CLI supplies `pack` and `unpack`.
- [7-Zip](https://www.7-zip.org/) supplies archive extraction.
- [xemu](https://xemu.app/) and [Xenia](https://github.com/xenia-project/xenia) are independent emulator projects, not bundled.

The scripts and documentation in this repository are licensed under the **GNU General Public License v3.0**; see [LICENSE](LICENSE). No upstream executables or game files are bundled.

**Status:** Initial Bazzite/Dolphin implementation; validate on a real Bazzite machine before tagging a stable v1.0.0 release.
