# searchjump.yazi

A Yazi plugin that it't the behavior consistent with flash.nvim in Neovim, allow use key char to precise selection.

> [!NOTE]
> The latest main branch of Yazi is required at the moment.


## Install

### Linux

```bash
git clone https://github.com/DreamMaoMao/searchjump.yazi.git ~/.config/yazi/plugins/searchjump.yazi
```

### Windows

With `Powershell` :

```powershell
if (!(Test-Path $env:APPDATA\yazi\config\plugins\)) {mkdir $env:APPDATA\yazi\config\plugins\}
git clone https://github.com/DreamMaoMao/searchjump.yazi.git $env:APPDATA\yazi\config\plugins\searchjump.yazi
```

## Usage

set shortcut key to toggle searchjump mode in `~/.config/yazi/keymap.toml`. for example set `i` to toggle searchjump mode

```toml
[[manager.prepend_keymap]]
on   = [ "i" ]
run = "plugin searchjump"
desc = "searchjump mode"
```

When you see some character singal lable in right of the entry.
Press the key of the character will jump to the corresponding entry
