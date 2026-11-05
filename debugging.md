# Debugging guide

The debugger works like Zed's. Both editors speak the same Debug Adapter Protocol (DAP) to the same debuggers:

| Language | Debugger | Zed `adapter` name |
|---|---|---|
| Go | delve (`dlv`) | `Delve` |
| Python | debugpy | `Debugpy` |
| Rust | codelldb | `CodeLLDB` |

Mason installs all three on first start (`:Mason` shows them).

Debug configurations live in **`.zed/debug.json`** in the project, the same file Zed reads, so one file works in both editors. Zed's own defaults are used too: stepping goes line by line, breakpoints are saved between sessions, and the debug panel docks at the bottom.

Leader is <kbd>Space</kbd>, written `␣` below.

---

## 1. Place breakpoints

Put the cursor on a line, then:

| Keys | Marker | What it does |
|---|---|---|
| `F9` or `␣ d b` | `` (red) | **Breakpoint.** Stops every time this line runs. Press again to remove it. |
| `␣ d B` | `` | **Conditional breakpoint.** Asks for a condition and stops only when it is true. The condition is written in the program's language: `len(items) > 3` (Go), `user is None` (Python), `count > 10` (Rust). |
| `␣ d h` | `` | **Hit-count breakpoint.** Asks for a number and stops only after the line has run that many times. Useful inside loops. |
| `␣ d L` | `` | **Logpoint.** Prints a message to the REPL and keeps running. Put expressions in braces: `total is {total}`. |
| `␣ d x` | | Clear every breakpoint. |

- Breakpoints are **saved when you quit** and come back when you reopen the file, with their conditions, hit counts and log messages. This is Zed's `save_breakpoints` setting. The saved list is in `~/.local/state/nvim/dap-breakpoints.json`.
- A breakpoint on a line with no code (a blank line, a comment, a closing brace) moves to the next line with code when the session starts.
- The line where the program is paused is highlighted, with an arrow `` in the sign column.

## 2. Start a debug session

| Keys | Action |
|---|---|
| `F5` | Start, or continue when paused. With no session running, it opens a picker of every configuration for this file. |
| `F4` | Always start a **new** session from the picker. This is Zed's `debugger: start`. |
| `␣ r d` | Debug the test under the cursor (through the test runner). No configuration needed. |
| `␣ d l` | Re-run the last debug session. |

The `F5` picker lists, in this order:

1. Scenarios from `.zed/debug.json`, marked `(.zed)`.
2. Scenarios from `.vscode/launch.json`, if the project has one.
3. The built-in configurations for the language (see each language below).

## 3. While paused

| Keys | Action |
|---|---|
| `F10` / `␣ d o` | Step over: run this line, stop on the next one. |
| `F11` / `␣ d i` | Step into the function called on this line. |
| `Shift-F11` / `␣ d O` | Step out: finish this function, stop in the caller. |
| `F5` / `␣ d c` | Continue to the next breakpoint. |
| `␣ d C` | Run to the cursor line. |
| `␣ d e` | Show the value of the expression under the cursor, or of the selection in visual mode. |
| `Shift-F5` / `␣ d t` | Stop the program. |
| `␣ d u` | Show or hide the debug panel. |
| `␣ d r` | Open the REPL to type expressions. |

Variable values also show at the end of each line while paused (inline value hints, as in Zed).

The **debug panel** opens at the bottom when a session starts and closes when it ends. From left to right:

- **Scopes**: local and global variables. Press `Enter` on a value to expand it.
- **Stacks**: the call stack. Press `Enter` to jump to a frame.
- **Watches**: expressions you add with `i`. They update at every stop.
- **Breakpoints**: all breakpoints. Press `Enter` to jump to one.
- **REPL**: program output and an expression prompt.

If `F10`, `F11` or `Shift-F11` do nothing, your terminal or macOS is using those keys. In that case use the `␣ d` versions, which always work.

---

## Go

**Without a config file:**

- Put the cursor inside a `func TestXxx` and press `␣ r d` to debug that test.
- Or press `F5` and pick one of the delve configurations:
  - `Debug`: the current file's package.
  - `Debug (Arguments)`: the same, but asks for arguments.
  - `Debug (Arguments & Build Flags)`: also asks for build flags such as `-tags integration`.
  - `Debug Package`: the package in the current directory.
  - `Debug test`: all tests in the current directory.
  - `Debug test (go.mod)`: all tests in the module.
  - `Attach`: pick a running Go process to attach to.

**With `.zed/debug.json`** (these are Zed's documented examples):

```jsonc
[
  {
    "label": "Run server",
    "adapter": "Delve",
    "request": "launch",
    "mode": "debug",
    "program": "./cmd/server", // for Delve, program can be a package
    "args": ["--port", "8080"],
    "env": { "APP_ENV": "dev" }
  },
  {
    "label": "Test under cursor",
    "adapter": "Delve",
    "request": "launch",
    "mode": "test",
    "program": ".",
    "args": ["-test.run", "$ZED_SYMBOL"],
    "buildFlags": ["-tags", "integration"]
  }
]
```

`$ZED_SYMBOL` is the name of the function the cursor is in, so `Test under cursor` debugs exactly the test you are looking at.

**Attach to a delve that is already running**, for example inside a container:

```sh
dlv dap --listen=127.0.0.1:53412
```

```jsonc
{
  "label": "Attach to running delve",
  "adapter": "Delve",
  "request": "launch",
  "mode": "exec",
  "program": "/abs/path/to/binary",
  "tcp_connection": { "host": "127.0.0.1", "port": 53412 }
}
```

## Python

**Without a config file:**

- Put the cursor inside a `def test_xxx` and press `␣ r d` to debug that test with pytest.
- Or press `F5` and pick a debugpy configuration:
  - `file`: run the current file.
  - `file:args`: run the current file, asking for arguments.
  - `attach`: connect to a running debugpy.

The program runs with the project's virtual environment. It looks for `$VIRTUAL_ENV`, `$CONDA_PREFIX`, then `./venv`, `./.venv`, `./env`, `./.env`, in that order. debugpy itself comes from Mason, so the project doesn't need it installed.

**With `.zed/debug.json`** (Zed's documented examples):

```jsonc
[
  {
    "label": "Python Active File",
    "adapter": "Debugpy",
    "program": "$ZED_FILE",
    "request": "launch"
  },
  {
    "label": "Python: Flask",
    "adapter": "Debugpy",
    "request": "launch",
    "module": "app",
    "cwd": "$ZED_WORKTREE_ROOT",
    "env": { "FLASK_APP": "app", "FLASK_DEBUG": "1" },
    "args": ["run", "--reload", "--debugger"],
    "jinja": true,
    "justMyCode": true
  },
  {
    "label": "Python: Django",
    "adapter": "Debugpy",
    "request": "launch",
    "program": "manage.py",
    "args": ["runserver"],
    "django": true
  }
]
```

Set `"justMyCode": false` to step into library code.

## Rust

**Without a config file:**

- Put the cursor inside a `#[test]` function and press `␣ r d`.
- Or press `F5`. The picker lists every binary and test target that cargo knows about, found by rust-analyzer.
- `:RustLsp debuggables` opens the same list.

The first run compiles a debug build, so it takes a moment. Open nvim at the crate or workspace root.

**With `.zed/debug.json`** (Zed's documented examples):

```jsonc
[
  {
    // Build, then debug the binary cargo just built (no "program" needed)
    "label": "Build & Debug native binary",
    "adapter": "CodeLLDB",
    "build": { "command": "cargo", "args": ["build"] },
    "sourceLanguages": ["rust"] // required for CodeLLDB with Rust
  },
  {
    "label": "Debug with explicit path",
    "adapter": "CodeLLDB",
    "request": "launch",
    "build": { "command": "cargo", "args": ["build", "--bin", "server"] },
    "program": "$ZED_WORKTREE_ROOT/target/debug/server",
    "args": ["--verbose"],
    "sourceLanguages": ["rust"]
  }
]
```

When `build` runs `cargo build` or `cargo test` and `program` is missing, the binary is found from cargo's output, as Zed does it. For `cargo test` builds, `--no-run` is added automatically.

---

## `.zed/debug.json` reference

The file is a JSON array. Comments and trailing commas are allowed. Each entry needs a `label` and an `adapter`.

| Key | Meaning |
|---|---|
| `label` | Name in the picker (shown with `(.zed)` after it). |
| `adapter` | `Delve`, `Debugpy` or `CodeLLDB`. Entries for other adapters are skipped. |
| `request` | `launch` (default) or `attach`. |
| `program` | What to debug. `~` and relative paths work. Relative paths start from `cwd`. |
| `cwd` | Working directory. Defaults to the project root (`$ZED_WORKTREE_ROOT`). |
| `build` | A command run before the debugger starts: `{ "command": "make", "args": ["build"] }`, or the `label` of a task in `.zed/tasks.json`. It runs through your shell. If it fails, the session doesn't start and the error is shown. |
| `tcp_connection` | `{ "host": "127.0.0.1", "port": 53412 }` connects to a debug adapter that is already running, without starting a new one. |
| anything else | Passed to the debugger as-is: `args`, `env`, `mode`, `buildFlags`, `module`, `justMyCode`, `stopOnEntry`, … |

**Variables** work in any string value. Use `$NAME`, `${NAME}`, or `${NAME:default}` to give a fallback.

| Variable | Value |
|---|---|
| `$ZED_WORKTREE_ROOT` | Project root: the nearest folder with `.zed/` or `.git/`, otherwise nvim's working directory. |
| `$ZED_MAIN_GIT_WORKTREE` | Same as the project root. |
| `$ZED_FILE` | Absolute path of the current file. |
| `$ZED_FILENAME` | `main.rs` |
| `$ZED_STEM` | `main` |
| `$ZED_DIRNAME` | Absolute folder of the current file. |
| `$ZED_RELATIVE_FILE` | `src/main.rs` |
| `$ZED_RELATIVE_DIR` | `src` |
| `$ZED_ROW`, `$ZED_COLUMN` | Cursor position. |
| `$ZED_SYMBOL` | Name of the function the cursor is in. |
| `$ZED_LANGUAGE` | `Go`, `Python`, `Rust`, … |

If an entry uses a variable that has no value right now (for example `$ZED_SYMBOL` with the cursor outside any function) and gives no default, that entry is left out of the picker, as in Zed. `$ZED_SELECTED_TEXT` and `$ZED_CUSTOM_RUST_PACKAGE` are not supported, so entries that use them never appear.

Global scenarios that apply to every project can go in Zed's global file: `~/Library/Application Support/Zed/debug.json` or `~/.config/zed/debug.json`.

**Differences from Zed:**

- Zed shows `.vscode/launch.json` only when `.zed/debug.json` has no entries. Here both are always listed.
- Breakpoints can't be disabled while kept visible, as Zed allows. Remove them with `F9` instead.
- Zed's `debugger.timeout`, `button` and log settings have no equivalent here.

## Troubleshooting

- **"No configuration found"**: Rust targets appear only after rust-analyzer has finished loading. Wait for the spinner in the bottom right to finish. For other languages, check the file type with `:set ft?`.
- **Breakpoint shows ``**: the debugger couldn't place it, usually because the code wasn't built with debug info, or the binary is older than the source.
- **Python stops in the wrong environment**: start nvim from inside the activated venv, or create `./.venv` (`uv venv`).
- **See what the debugger is doing**: `:lua require('dap').set_log_level('TRACE')`, then `:DapShowLog`.
- **Check `.zed/debug.json` support**: `nvim -l tests/zed_debug_test.lua`.
