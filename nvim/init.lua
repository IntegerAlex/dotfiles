-- Initialize packer.nvim for plugin management
require('packer').startup(function(use)
  -- Plugin Manager
  use 'wbthomason/packer.nvim'
  use 'OXY2DEV/markview.nvim'
  use 'nvzone/typr'
  use 'nvzone/volt'
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
  use 'agude/vim-eldar'
  use 'navarasu/onedark.nvim'
  use 'neanias/everforest-nvim'
  use 'oonamo/ef-themes.nvim'
  use 'alexxGmZ/e-ink.nvim'
  -- Utility Plugins
  use 'akinsho/toggleterm.nvim'

end)

-- Color Scheme
--vim.cmd [[colorscheme gruvbox]]
-- Lua
--require('onedark').setup {
 -- style = 'darker'
--}
--require('onedark').load()

--vim.cmd([[colorscheme eldar]])
--vim.cmd([[colorscheme ef-dark]])
vim.cmd([[colorscheme e-ink]])
-- Disable Netrw menu and related settings
vim.g.netrw_banner = 0        -- Disable the Netrw banner
vim.g.netrw_liststyle = 3     -- Use tree-style listing (remove default menu)
vim.g.netrw_altv = 1          -- Open splits to the right when Netrw is opened
vim.g.netrw_fastbrowse = 0    -- Disable fast browsing
vim.g.netrw_winsize = 25      -- Set window size for Netrw

vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n','ss',':Ex <CR>', { noremap = true, silent = true })
-- General Settings
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.termguicolors = true

-- LSP Configuration
local lspconfig = require('lspconfig')
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
	 vim.diagnostic.config({ update_in_insert = true })
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

-- Toggleterm Configuration
require("toggleterm").setup{
        -- Optional settings, adjust as needed
        size = 20,
        open_mapping = [[<c-\>]],
        direction = 'float',
        shade_terminals = true,
        highlights = {
          border = "Normal",
          background = "Normal",
        }
      }

-- Enable LSP Servers
lspconfig.ts_ls.setup { on_attach = on_attach }
lspconfig.pyright.setup { on_attach = on_attach }
lspconfig.ccls.setup{
  cmd = {"ccls"}, -- Path to the ccls executable
  filetypes = {"c", "cpp", "objc", "objcpp"}, -- Supported file types
  root_dir = lspconfig.util.root_pattern("compile_commands.json", ".ccls", ".git"),
  init_options = {
    cache = {
      directory = ".ccls-cache" -- Cache directory
    },
    compilationDatabaseDirectory = "build", -- Directory for compile_commands.json
    clang = {
      extraArgs = {"-std=gnu11", "-Wall", "-Wextra", "-pedantic"}, -- Custom flags
      excludeArgs = {"-frounding-math"} -- Exclude problematic flags
    }
  },
  capabilities = require('cmp_nvim_lsp').default_capabilities() -- Optional: Enable autocompletion support if using nvim-cmp
}
require'lspconfig'.clangd.setup{}
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
  ensure_installed = { "javascript", "typescript", "lua", "python" ,"c","cpp"},
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
	['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
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

require('gitsigns').setup()

-- UI Enhancements
require('lualine').setup {
 options = {
    theme = 'gruvbox',  -- Choose your theme
    icons_enabled = true,  -- Enable icons for a better look
    section_separators = {'', ''},
    component_separators = {'', ''},
  },
  sections = {
    lualine_a = {'mode'},  -- Current mode (Normal, Insert, etc.)
    lualine_b = {'branch', 
                 'diff', 
                 'diagnostics'},  -- Git branch, diff, and diagnostics
    lualine_c = {'filename'},  -- File name
    lualine_x = {'encoding', 'fileformat', 'filetype'},  -- Encoding, file format, and type
    lualine_y = {'progress'},  -- Progress (line number/total lines)
  },
  inactive_sections = {
    lualine_a = {'filename'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
},
}
-- Utility Plugins Setup

require('markview').setup({
  -- Default settings for markview
  preview = {
    -- Automatically show preview in a split window when entering Markdown mode
    auto_open = true,    -- Keep auto_open true for seamless experience
    -- Customize the location of the preview window
    location = "right",  -- 'right' or 'bottom' for preview location
    width = 35,          -- Increase width for more comfortable preview area
    height = 25,         -- Increase height for better content visibility
    -- You can also add more options if needed, like border or padding
  },
  -- Syntax highlighting settings
  syntax_highlighting = true,  -- Enable/disable syntax highlighting in preview

  -- Advanced table of supported markdown features, enable/disable as needed
  features = {
    code_folding = true,     -- Code folding in preview is handy for navigation
    line_numbers = true,     -- Line numbers help with readability and debugging
    syntax_highlight = true, -- Syntax highlighting is a must for clarity
    smart_wrapping = true,   -- Add smart word wrapping (optional)
    auto_highlight_links = true,  -- Highlight links in preview for easier navigation
    emoji_support = true,    -- Add support for rendering emojis (optional)
  },
  
  -- Key bindings for markview actions, ensure they match your workflow
  keymaps = {
    -- Open/close preview using leader key
    toggle_preview = "<Leader>mp",    -- Toggle preview
    refresh_preview = "<Leader>mr",   -- Refresh preview
    focus_preview = "<Leader>mP",     -- Focus the preview window (new keybinding)
    close_preview = "<Leader>mc",     -- Close the preview window (new keybinding)
  },

  -- Optionally, configure rendering settings like theme for preview window
  preview_theme = "default",  -- You can also set a custom theme (e.g., "dark", "light")
})

