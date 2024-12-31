-- Initialize packer.nvim for plugin management
require('packer').startup(function(use)
  -- Plugin Manager
  use 'wbthomason/packer.nvim'

  -- Core Plugins
  use 'neovim/nvim-lspconfig' -- LSP
  use 'nvim-telescope/telescope.nvim' -- Telescope
  use 'nvim-lua/plenary.nvim' -- Dependency for Telescope

  -- Syntax Highlighting
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Completion Framework
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'

  -- Snippets
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- Debugging Tools

  -- UI Enhancements
  use 'hoob3rt/lualine.nvim' -- Statusline

  -- Git Integration
  use 'lewis6991/gitsigns.nvim'

  -- Navigation
  use 'ThePrimeagen/harpoon'

  -- Color Scheme
  use 'gruvbox-community/gruvbox'

  -- Utility Plugins
end)
-- Disable Netrw menu and related settings
vim.g.netrw_banner = 0        -- Disable the Netrw banner
vim.g.netrw_liststyle = 3     -- Use tree-style listing (remove default menu)
vim.g.netrw_altv = 1          -- Open splits to the right when Netrw is opened
vim.g.netrw_fastbrowse = 0    -- Disable fast browsing
vim.g.netrw_winsize = 25      -- Set window size for Netrw

vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
vim.g.mapleader = ' '
-- General Settings
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.termguicolors = true

-- LSP Configuration
local lspconfig = require('lspconfig')
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap

  -- LSP Keybindings
  keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

  -- Telescope Integration
  vim.keymap.set('n', '<leader>gd', require('telescope.builtin').lsp_definitions, { buffer = bufnr })
  vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, { buffer = bufnr })
end

-- Enable LSP Servers
lspconfig.tsserver.setup { on_attach = on_attach }
lspconfig.pyright.setup { on_attach = on_attach }

-- Telescope Setup
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "node_modules", ".git" },
  },
}

-- Telescope Key Bindings
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { noremap = true, silent = true })

-- Treesitter Setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { "javascript", "typescript", "lua", "python" },
  highlight = { enable = true },
}

-- Harpoon Setup
local harpoon = require('harpoon')
require('harpoon').setup()

-- Harpoon Key Bindings
vim.keymap.set('n', '<C-a>', require('harpoon.mark').add_file, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hm', require('harpoon.ui').toggle_quick_menu, { noremap = true, silent = true })
vim.keymap.set('n', '<C-h>', function() require('harpoon.ui').nav_file(1) end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', function() require('harpoon.ui').nav_file(2) end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', function() require('harpoon.ui').nav_file(3) end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', function() require('harpoon.ui').nav_file(4) end, { noremap = true, silent = true })

-- Completion Configuration
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})

-- Debugging Setup

-- UI Enhancements
require('lualine').setup { options = { theme = 'gruvbox' } }

-- Utility Plugins Setup

-- Color Scheme
vim.cmd [[colorscheme gruvbox]]

