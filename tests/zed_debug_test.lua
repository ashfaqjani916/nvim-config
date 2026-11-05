-- Self-check for lua/custom/zed_debug.lua. Run: nvim -l tests/zed_debug_test.lua
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, 'S').source:sub(2))))
package.path = root .. '/lua/?.lua;' .. package.path
local zed = require 'custom.zed_debug'

-- JSONC: comments and trailing commas go, strings keep "//" and ","
local parsed = vim.json.decode(zed.strip_jsonc [[
[
  // a comment
  { "label": "a // not a comment", "args": ["x,", "y",], /* block */ "adapter": "Delve", },
]
]])
assert(#parsed == 1 and parsed[1].label == 'a // not a comment', 'comment stripping')
assert(vim.deep_equal(parsed[1].args, { 'x,', 'y' }), 'trailing comma inside array')

-- Variables: $X, ${X}, ${X:default}; missing variable without default hides the scenario
local vars = { ZED_WORKTREE_ROOT = '/proj', ZED_SYMBOL = 'TestAdd' }
assert(zed.substitute('$ZED_WORKTREE_ROOT/bin', vars) == '/proj/bin', '$VAR')
assert(zed.substitute('${ZED_WORKTREE_ROOT}/__debug', vars) == '/proj/__debug', '${VAR}')
assert(zed.substitute('${ZED_FILE:main.go}', vars) == 'main.go', '${VAR:default}')
assert(zed.substitute('${workspaceFolder}', vars) == '${workspaceFolder}', 'nvim-dap variables untouched')
assert(zed.substitute({ args = { '-test.run', '$ZED_FILE' } }, vars) == nil, 'missing variable hides scenario')

-- Scenario -> nvim-dap configuration
local cfg = zed.to_dap({ label = 'Tests', adapter = 'Delve', mode = 'test', program = '.', args = { '-test.run', '$ZED_SYMBOL' } }, vars, '/proj', {})
assert(cfg.type == 'go' and cfg.name == 'Tests (.zed)' and cfg.request == 'launch' and cfg.cwd == '/proj', 'mapping')
assert(cfg.label == nil and cfg.adapter == nil and cfg.args[2] == 'TestAdd', 'Zed-only keys removed, symbol filled')
assert(zed.to_dap({ label = 'x', adapter = 'GDB' }, vars, '/proj', {}) == nil, 'unknown adapter skipped')

-- `build` as a task label resolves from .zed/tasks.json; unknown label hides the scenario
local tasks = { ['cargo build'] = { label = 'cargo build', command = 'cargo', args = { 'build' } } }
local built = zed.to_dap({ label = 'R', adapter = 'CodeLLDB', build = 'cargo build' }, vars, '/proj', tasks)
assert(built.build.command == 'cargo' and built.type == 'codelldb', 'build task lookup')
assert(zed.to_dap({ label = 'R', adapter = 'CodeLLDB', build = 'nope' }, vars, '/proj', tasks) == nil, 'unknown build task')

print 'zed_debug: all checks passed'
