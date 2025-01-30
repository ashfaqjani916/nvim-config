
return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css","javascript","typescript","tsx","go","java"
      },
    },
  },


{
  "windwp/nvim-ts-autotag",
  config = function()
    require("nvim-ts-autotag").setup {
      filetypes = {
        "html",
        "xml",
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "markdown",
      },
    }
  end,
  event = "InsertEnter", -- Load on entering insert mode
}
}
