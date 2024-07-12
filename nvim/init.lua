-- Install packer.nvim if not installed
vim.g.mapleader = ' '
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

-- Use packer.nvim to manage plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'  -- LSP configurations
  use 'nvim-treesitter/nvim-treesitter'  -- Tree-sitter for syntax highlighting
  use 'nvim-treesitter/nvim-treesitter-textobjects'  -- Tree-sitter textobjects
  use 'hrsh7th/nvim-cmp'  -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'  -- LSP completion source for nvim-cmp
  use 'hrsh7th/cmp-buffer'    -- Buffer completion source for nvim-cmp
  use 'hrsh7th/cmp-path'      -- Path completion source for nvim-cmp
  use 'hrsh7th/cmp-nvim-lua'  -- Lua completion source for nvim-cmp
 -- use 'hrsh7th/cmp-treesitter'  -- Treesitter completion source for nvim-cmp
  use 'hrsh7th/cmp-vsnip'     -- Snippet support for nvim-cmp
  use 'hrsh7th/vim-vsnip'     -- Vsnip snippets plugin
  use 'hrsh7th/vim-vsnip-integ'  -- Integration between nvim-cmp and vim-vsnip
  use 'nvim-lua/completion-nvim'  -- Additional completion enhancements
  use 'ellisonleao/gruvbox.nvim' 
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  -- Add other plugins as needed
end)

-- Example configuration to map 'jj' to '<Esc>'
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })

-- LSP configuration
local lspconfig = require('lspconfig')
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.diagnostic.config({ update_in_insert = true })
  -- Mappings.
  local opts = { noremap=true, silent=true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- Set autocommands to ensure omnifunc is set correctly
  vim.cmd [[
    augroup LspAutocommands
      autocmd! * <buffer>
      autocmd BufEnter,InsertEnter <buffer> setlocal omnifunc=v:lua.vim.lsp.omnifunc
    augroup END
  ]]

  -- Print a message to ensure the on_attach function is called
  print('LSP attached to buffer ' .. bufnr)
end
--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require'lspconfig'.html.setup {
  capabilities = capabilities,
}
-- Configure LSP servers
lspconfig.tsserver.setup{
  on_attach = on_attach,
  capabilities = vim.lsp.protocol.make_client_capabilities()  -- optional capabilities
}

lspconfig.gopls.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- Treesitter setup
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
	  "go",
    "python",           -- Python
    "javascript",       -- JavaScript
    "typescript",       -- TypeScript
    "html",             -- HTML
    "css",              -- CSS
    "lua",              -- Lua
    "tsx"
    -- TSX (TypeScript JSX)
  },
  highlight = {
    enable = true,      -- Enable Treesitter syntax highlighting
  },
}

-- nvim-cmp setup
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)  -- For `vim-vsnip` users.
    end,
  },
  mapping  = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-o>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
  sources = {
    { name = 'nvim_lsp' },     -- LSP as a source
    { name = 'buffer' },       -- Buffers as a source
    { name = 'path' },         -- File path completion
    { name = 'nvim_lua' },     -- Neovim Lua API
    { name = 'treesitter' },   -- Treesitter
  },
})

-- Default options:
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
  }
