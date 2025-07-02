-- ~/.config/nvim/lua/lsp_setup.lua

-- LSP and Autocompletion Setup

-- Load Mason (LSP Installer)
require("mason").setup()
require("mason-lspconfig").setup()

-- Setup LSP servers
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Use table instead of list to avoid deprecated tsserver setup
local servers = {
  pyright = {},
  ts_ls = {},
  cssls = {},
  html = {},
  lua_ls = {}
}

for name, config in pairs(servers) do
  lspconfig[name].setup({
    capabilities = capabilities,
    settings = config,
  })
end

-- Setup nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

lspconfig.html.setup({
  on_attach = function(client, bufnr)
    -- Auto format on save
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

lspconfig.cssls.setup({
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})


lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if client.server_capabilities.documentFormattingProvider then
          vim.lsp.buf.format({ async = false })
        else
          vim.cmd([[silent! write]])
          vim.cmd([[silent! !black --quiet %]])
          vim.cmd([[edit!]])
        end
      end,
    })
  end,
})


