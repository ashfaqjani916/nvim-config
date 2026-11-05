# nvim-config

A Neovim setup that works as an IDE for **Go, Python and Rust**. It's modelled on Zed: the file tree docks right, the outline left, terminals at the bottom, and the debugger reads Zed's `.zed/debug.json`. The colours are the **Cinder Peak** theme from the Rex terminal.

Built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), with plugins managed by Neovim's built-in `vim.pack`.

| Guide | What's in it |
|---|---|
| [usage.md](usage.md) | Every keybinding, the window layout, what was verified per language |
| [debugging.md](debugging.md) | Breakpoints, starting the debugger in Go / Python / Rust, `.zed/debug.json` |

## What you get

| | Go | Python | Rust |
|---|---|---|---|
| Language server | gopls (staticcheck) | basedpyright + ruff | rust-analyzer (rustaceanvim, clippy) |
| Tests (neotest) | `go test -race` | pytest | cargo test |
| Debugger | delve | debugpy | codelldb |
| Format on save | goimports, gofmt | ruff | rustfmt |

You also get:
- completion (blink.cmp)
- treesitter highlighting with sticky scroll
- git hunks (gitsigns) and lazygit
- telescope search
- an outline panel (aerial)
- which-key hints

## Requirements

- **Neovim 0.12+**, which includes `vim.pack`.
- `git`, `make`, a C compiler, `rg` (ripgrep), `fd`.
- A Nerd Font in your terminal (JetBrainsMono Nerd Font is used here).
- Language toolchains: `go`, `python3`, `rustup`/`cargo`. `uv` is handy for Python venvs.
- Optional: `lazygit` for `␣ g g`. On macOS, `lldb-dap` comes with Xcode, but codelldb from Mason is what's used.

Mason installs the language servers, formatters and debuggers itself:
- gopls, goimports, delve
- basedpyright, ruff, debugpy
- rust-analyzer, codelldb
- lua-language-server, stylua

## Install

```sh
mv ~/.config/nvim ~/.config/nvim.bak   # keep any old config
git clone git@github.com:ashfaqjani916/nvim-config.git ~/.config/nvim
nvim
```

On first start, `vim.pack` asks to install the plugins and Mason installs its tools in the background. Restart once both have finished. `:checkhealth` reports anything missing.

For Python projects, install pytest in the project's venv (`uv add --dev pytest`).

## Layout

```
init.lua                          options, keymaps, LSP, formatting, completion, treesitter
colors/cinder-peak.lua            Rex "Cinder Peak" theme (on mini.base16)
lua/kickstart/plugins/
  debug.lua                       nvim-dap + dap-ui, Zed debugger defaults, saved breakpoints
  neo-tree.lua                    file tree, docked right
  autopairs.lua, indent_line.lua
lua/custom/
  zed_debug.lua                   reads .zed/debug.json (Zed debug scenarios)
  plugins/                        every file here loads automatically
    test.lua                      neotest: Go, pytest, Rust
    terminal.lua                  bottom terminals, run project, lazygit (snacks.nvim)
    editor.lua                    sticky scroll, outline panel
    markdown.lua, html.lua        markdown rendering, HTML live preview
tests/zed_debug_test.lua          self-check: nvim -l tests/zed_debug_test.lua
nvim-pack-lock.json               pinned plugin versions
```

## Everyday commands

| Command | Does |
|---|---|
| `:lua vim.pack.update()` | Update plugins (review, then `:write` to apply) |
| `:Mason` | See or update language servers and debuggers |
| `:checkhealth` | Diagnose missing tools |
| `nvim -l tests/zed_debug_test.lua` | Check the `.zed/debug.json` support |

## Changing things

- **Theme:** edit `colors/cinder-peak.lua`. `base00` is the background.
- **Language servers:** the `servers` table in `init.lua` (Section 6).
- **Formatters:** `formatters_by_ft` in `init.lua` (Section 7).
- **New plugin:** add a file to `lua/custom/plugins/` and it loads on start.
