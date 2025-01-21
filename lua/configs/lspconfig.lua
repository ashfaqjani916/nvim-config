
-- Load NvChad default LSP settings
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- LSP servers list for setup with default config
local servers = { "html", "cssls", "gopls", "jdtls" }

-- Setup servers with default settings from NvChad
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- Custom setup for `eslint_lsp`
lspconfig.eslint.setup {
  on_attach = function(client, bufnr)
    -- Enable auto-fix on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
    nvlsp.on_attach(client, bufnr)
  end,
  capabilities = nvlsp.capabilities,
}

-- Custom setup for `ast-grep`
lspconfig.ast_grep.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  cmd = { "sg", "lsp" }, -- Ensure `sg` is available in your PATH
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css" },
  settings = {
    -- Example: Add custom patterns or rules
    enable = true,
    patterns = {
      js = { "console.log", "debugger" }, -- Highlight these patterns
    },
  },
}
