# Neovim IDE Keymap

Neovim 0.12 · kickstart + `vim.pack` · Go, Python and Rust

Language servers, a test runner, a debugger, a file tree docked right, terminals docked bottom, and the Rex "Cinder Peak" colours. The layout follows the Zed settings.

- Leader is <kbd>Space</kbd> (written `␣` below).
- Press <kbd>Space</kbd> and wait: which-key lists every group.
- `␣ s k` searches all keymaps.

## Where things open

```
┌──────────┬──────────────────────────────┬────────────┐
│ Outline  │ Editor                       │ File tree  │
│ ␣ o      │ sticky scope header at top   │ ␣ e        │
│ (aerial) │ inline diagnostics, ✓/✗ marks│ git + diag │
│          │ breakpoints in sign column   │ badges     │
├──────────┴──────────────────────────────┴────────────┤
│ Terminals: Ctrl-/ toggles · 2 Ctrl-/ opens terminal 2│
│ ␣ t n adds one · ␣ r r runs the project here         │
└──────────────────────────────────────────────────────┘
```

Matches Zed: project panel right, outline panel left, terminal dock bottom. The debugger UI opens on its own while a session runs.

## Keymap

### Terminal (bottom dock)

| Keys | Action |
|---|---|
| `Ctrl-/` | Toggle bottom terminal (normal and terminal mode) |
| `2 Ctrl-/` | Toggle terminal number 2 (any count works) |
| `␣ t t` | Toggle terminal (same as `Ctrl-/`) |
| `␣ t n` | Open a new terminal with the next free number |
| `Esc Esc` | Terminal mode → normal mode (scroll, copy) |
| `Alt-h/j/k/l` | Leave the terminal for the window in that direction |
| `␣ r r` | Run project: `go run .` / `python3 file` / `cargo run` |
| `␣ g g` | Lazygit (floating) |

### Tests (neotest)

| Keys | Action |
|---|---|
| `␣ r t` | Run nearest test |
| `␣ r f` | Run all tests in this file |
| `␣ r a` | Run the whole suite (project root) |
| `␣ r l` | Re-run last test |
| `␣ r d` | Debug nearest test (stops on breakpoints) |
| `␣ r w` | Watch file: re-run on save |
| `␣ r x` | Stop running tests |
| `␣ r s` | Test summary tree |
| `␣ r o` | Output of test under cursor |
| `␣ r O` | Toggle output panel |
| `]t` / `[t` | Next / previous failed test |

### Debugger (VS Code keys + `␣ d`)

Works like Zed's debugger and reads the same `.zed/debug.json`. Breakpoints are saved across restarts. Full guide: [debugging.md](debugging.md).


| Keys | Action |
|---|---|
| `F4` | Start a new session from the picker (Zed: `debugger: start`) |
| `F5` | Start (picker: `.zed/debug.json`, `.vscode/launch.json`, built-ins) / continue |
| `Shift-F5` | Stop |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `Shift-F11` | Step out |
| `␣ d b` | Toggle breakpoint |
| `␣ d B` | Conditional breakpoint |
| `␣ d h` | Hit-count breakpoint (stop after N hits) |
| `␣ d L` | Logpoint (prints `{expr}` values, doesn't stop) |
| `␣ d c` | Continue / start |
| `␣ d o` / `i` / `O` | Step over / into / out |
| `␣ d C` | Run to cursor |
| `␣ d l` | Re-run last debug session |
| `␣ d t` | Terminate |
| `␣ d e` | Evaluate expression under cursor / selection |
| `␣ d u` | Toggle debugger UI |
| `␣ d r` | Toggle REPL |
| `␣ d x` | Clear all breakpoints |

### Code intelligence (LSP)

| Keys | Action |
|---|---|
| `K` | Hover docs |
| `grd` | Go to definition |
| `grr` | Find references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grD` | Go to declaration |
| `grn` | Rename symbol |
| `gra` | Code action / quick fix |
| `gO` | Symbols in this file |
| `gW` | Symbols in workspace |
| `]d` / `[d` | Next / previous diagnostic |
| `␣ q` | Diagnostics list |
| `␣ t h` | Toggle inlay hints |
| `␣ f` | Format now (also on save for Go, Python, Rust) |

### Files & panels

| Keys | Action |
|---|---|
| `␣ e` | Toggle file tree (right) and reveal current file |
| `\` | Reveal in tree / close tree from inside it |
| `Enter` / `P` / `O` | In tree: open / open in vsplit / open in split |
| `␣ o` | Toggle outline panel (left) |
| `␣ x` | Close buffer, keep the window |
| `Ctrl-h/j/k/l` | Move between windows (`Alt-h/j/k/l` too) |

### Search (telescope)

| Keys | Action |
|---|---|
| `␣ s f` | Find files |
| `␣ s g` | Grep project |
| `␣ s w` | Grep word under cursor |
| `␣ ␣` | Open buffers |
| `␣ s .` | Recent files |
| `␣ /` | Fuzzy search this buffer |
| `␣ s d` | Search diagnostics |
| `␣ s r` | Resume last search |
| `␣ s k` | Search keymaps |

### Git

| Keys | Action |
|---|---|
| `]c` / `[c` | Next / previous change |
| `␣ h s` | Stage hunk |
| `␣ h r` | Reset hunk |
| `␣ h p` | Preview hunk |
| `␣ h b` | Blame line |
| `␣ h d` | Diff against index |
| `␣ t b` | Toggle inline blame |
| `␣ g g` | Lazygit |

### Completion (insert mode)

| Keys | Action |
|---|---|
| `Ctrl-y` | Accept (auto-imports when the server offers it) |
| `Ctrl-n` / `Ctrl-p` | Next / previous item |
| `Ctrl-Space` | Open menu / docs |
| `Ctrl-e` | Close menu |
| `Ctrl-k` | Toggle signature help |
| `Tab` / `Shift-Tab` | Jump through snippet fields |

## Per language, verified

Each row was checked headless against a small sample project that has one passing and one failing test. Tests reported 1 passed, 1 failed as expected, and the debugger stopped on a breakpoint set in the source file.

| Language | Language server | Tests | Debugger | Format on save |
|---|---|---|---|---|
| **Go** | ✓ gopls (staticcheck, inlay hints, code lenses) | ✓ neotest-golang (`go test -v -race -count=1`) | ✓ delve | goimports → gofmt |
| **Python** | ✓ basedpyright + ruff | ✓ pytest (uses `./.venv` when present) | ✓ debugpy | ruff imports → ruff format |
| **Rust** | ✓ rust-analyzer via rustaceanvim (clippy on save) | ✓ rustaceanvim adapter (`cargo test`) | ✓ codelldb | rustfmt |

## Before you start

- **Python:** pytest must be installed in the project's environment (`uv add --dev pytest`). The test runner and debugger use `./.venv`, `./venv` or `$VIRTUAL_ENV` automatically.
- **Rust:** the first `F5` compiles a debug build. Rust debugging was verified with Neovim opened at the crate root, which is the normal way to work.
- **Debugging:** see [debugging.md](debugging.md) for breakpoints, per-language setup and `.zed/debug.json`.
- **Go:** `F5` asks which configuration to use: file, package or test. To debug one test, put the cursor in it and press `␣ r d`.
- Mason installs language servers and debuggers on startup. Run `:Mason` to see them.
- Indentation is 2 spaces by default, as in Zed. Go keeps tabs and Python/Rust keep 4 spaces, set by their filetype plugins.

## Not set up

- **golangci-lint** isn't wired into the editor. gopls already runs staticcheck. Run golangci-lint in a terminal (`Ctrl-/`).
- **Zed AI and edit predictions** have no equivalent here.
- **Zed's 5-tab limit and tab bar** aren't copied. Use `␣ ␣` to switch buffers.
- **``Ctrl-` ``** is mapped, but many terminals send nothing for it. `Ctrl-/` always works.
- **tokyonight** is no longer loaded but is still on disk. Remove it with `:lua vim.pack.del { 'tokyonight.nvim' }`.

## Files

| File | What it does |
|---|---|
| `colors/cinder-peak.lua` | Rex's Cinder Peak palette (from the app's themes.json) on mini.base16, background a shade darker than Rex. Embedded terminals use Rex's 16 ANSI colours. |
| `init.lua` | Nerd Font on, 2-space default, the colorscheme, gopls / basedpyright / ruff servers, rustaceanvim, Mason tools (goimports, rust-analyzer, delve, debugpy, codelldb), formatters, treesitter parsers, docs popup in completion. Debug, indent guides and autopairs switched on. |
| `lua/kickstart/plugins/debug.lua` | Debugger for Go, Python and Rust with Zed's defaults (line stepping, saved breakpoints, panel docked bottom), VS Code F-keys, inline values. |
| `lua/custom/zed_debug.lua` | Reads Zed's `.zed/debug.json`: adapter names, `$ZED_*` variables, `build`, `tcp_connection`. Checked by `tests/zed_debug_test.lua`. |
| `lua/kickstart/plugins/neo-tree.lua` | Tree docked right, hidden and gitignored files shown, file watcher. |
| `lua/custom/plugins/test.lua` | neotest with Go, pytest and Rust adapters. |
| `lua/custom/plugins/terminal.lua` | Bottom terminals, run project and lazygit, using snacks.nvim. |
| `lua/custom/plugins/editor.lua` | Sticky scroll (treesitter-context) and outline panel (aerial). |
