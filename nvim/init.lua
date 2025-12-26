-- ~/.config/nvim/init.lua
-- Modern Neovim config with Pyrefly, Mason, and fixed LSP setup

-- Set leader key before anything else
vim.g.mapleader = ' '
vim.g.localleader = ' '

-- Bootstrap Packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd('packadd packer.nvim')
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Packer plugin configuration
require('packer').startup(function(use)
  -- Core plugins
  use 'wbthomason/packer.nvim' -- Plugin manager
  use 'nvim-lua/plenary.nvim' -- Required for Telescope
  
  -- UI & Appearance
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  use 'Mofiqul/vscode.nvim' -- Modern colorscheme alternative
  use 'gruvbox-community/gruvbox' -- Your preferred colorscheme
  
  -- Telescope (file finder, grep, etc.)
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  -- Treesitter (syntax highlighting, code analysis)
  use {
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate'
}

  -- LSP & Completion
  use 'neovim/nvim-lspconfig' -- LSP configuration
  use 'williamboman/mason.nvim' -- LSP installer
  use 'williamboman/mason-lspconfig.nvim' -- Mason + LSP integration
  
  -- Completion
  use 'hrsh7th/nvim-cmp' -- Completion framework
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer' -- Buffer source
  use 'hrsh7th/cmp-path' -- Path source
  use 'saadparwaiz1/cmp_luasnip' -- Snippet source
  use 'L3MON4D3/LuaSnip' -- Snippet engine
  
  -- Git integration
  use 'lewis6991/gitsigns.nvim'
  
  -- Navigation & productivity
  use 'ThePrimeagen/harpoon'
  use 'akinsho/toggleterm.nvim'
  
  -- Markdown preview
  use 'OXY2DEV/markview.nvim'
  
  -- Extra utilities
  use 'nvzone/typr'
  use 'nvzone/volt'
  
  -- Color schemes (keep your favorites)
  use 'agude/vim-eldar'
  use 'navarasu/onedark.nvim'
  use 'neanias/everforest-nvim'
  use 'oonamo/ef-themes.nvim'
  use 'alexxGmZ/e-ink.nvim'
end)

-- If Packer was just installed, compile and sync
if packer_bootstrap then
  require('packer').sync()
  vim.cmd('autocmd BufWritePost init.lua source <afile> | PackerCompile')
end

-- Set options
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'

-- Keymaps
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ss', ':Ex<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })

-- Colorscheme
vim.cmd('colorscheme gruvbox')
vim.cmd('set background=dark')

-- Disable Netrw banner and customize
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_altv = 1
vim.g.netrw_fastbrowse = 0
vim.g.netrw_winsize = 25

-- Mason setup (LSP installer)
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- Mason LSP Config setup
require('mason-lspconfig').setup({
  ensure_installed = {
    'pyrefly',    -- Python LSP (replacing pyright)
    'clangd',     -- C/C++ LSP
    'ts_ls',      -- TypeScript/JavaScript LSP
    'lua_ls',     -- Lua LSP
  },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
    -- Custom handler for pyrefly
    ['pyrefly'] = function()
      require('lspconfig').pyrefly.setup({
        cmd = { "pyrefly", "lsp" },
        filetypes = { "python" },
        root_dir = require('lspconfig.util').root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git"),
        settings = {
          pyrefly = {
            typeCheckingMode = "basic",
            lintingMode = "on",
          }
        },
        on_attach = function(client, bufnr)
          -- Attach common keymaps and settings
          require('lsp-keymaps')(bufnr)
        end,
      })
    end,
    -- Custom handler for clangd
    ['clangd'] = function()
      require('lspconfig').clangd.setup({
        on_attach = function(client, bufnr)
          require('lsp-keymaps')(bufnr)
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })
    end,
    -- Custom handler for ts_ls
    ['ts_ls'] = function()
      require('lspconfig').ts_ls.setup({
        on_attach = function(client, bufnr)
          require('lsp-keymaps')(bufnr)
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })
    end,
    -- Custom handler for lua_ls
    ['lua_ls'] = function()
      require('lspconfig').lua_ls.setup({
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
        on_attach = function(client, bufnr)
          require('lsp-keymaps')(bufnr)
        end,
      })
    end,
  }
})

-- Create module for LSP keymaps
_G.lsp_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Basic LSP keymaps
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
  
  -- Diagnostics navigation
  vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  
  -- Telescope LSP integration
  vim.keymap.set('n', '<leader>gd', require('telescope.builtin').lsp_definitions, opts)
  vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, opts)
  vim.keymap.set('n', '<leader>gi', require('telescope.builtin').lsp_implementations, opts)
  vim.keymap.set('n', '<leader>gt', require('telescope.builtin').lsp_type_definitions, opts)
  
  -- Setup cmp capabilities
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  vim.lsp.buf_attach_client(bufnr, capabilities)
end

-- Setup nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = function(entry, vim_item)
      -- Icons for different completion types
      local kind_icons = {
        Text = " ",
        Method = " ",
        Function = " ",
        Constructor = " ",
        Field = " ",
        Variable = " ",
        Class = " ",
        Interface = " ",
        Module = " ",
        Property = " ",
        Unit = " ",
        Value = " ",
        Enum = " ",
        Keyword = " ",
        Snippet = " ",
        Color = " ",
        File = " ",
        Reference = " ",
        Folder = " ",
        EnumMember = " ",
        Constant = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      }
      vim_item.kind = (kind_icons[vim_item.kind] or "") .. vim_item.kind
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

-- Setup telescope
require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
    file_ignore_patterns = {
      "node_modules",
      "%.git",
      "%.cache",
      "%.rustup",
      "%.cargo",
      "%.local",
    },
    preview = {
      treescope = true,
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Live Grep" })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = "Find Buffers" })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = "Help Tags" })
vim.keymap.set('n', '<leader>fr', require('telescope.builtin').registers, { desc = "Registers" })
vim.keymap.set('n', '<leader>fk', require('telescope.builtin').keymaps, { desc = "Keymaps" })

-- Setup gitsigns
require('gitsigns').setup({
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
    changedelete = { text = '▎' },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
  },
  numhl = true,
  linehl = false,
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return ''
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return ''
    end, { expr = true })

    -- Actions
    map('n', '<leader>hs', gs.stage_hunk)
    map('n', '<leader>hr', gs.reset_hunk)
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', gs.blame_line)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>td', gs.toggle_deleted)
  end,
})

-- Setup lualine
require('lualine').setup({
  options = {
    theme = 'gruvbox',
    icons_enabled = true,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
})

-- Setup harpoon
require('harpoon').setup({
  menu = {
    width = 80,
    height = 25,
    with_preview = true,
    position = "middle",
  },
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
  }
})

-- Harpoon keymaps
vim.keymap.set('n', '<C-a>', function() require('harpoon.mark').add_file() end, { desc = "Add file to Harpoon" })
vim.keymap.set('n', '<leader>hm', function() require('harpoon.ui').toggle_quick_menu() end, { desc = "Toggle Harpoon menu" })
vim.keymap.set('n', '<C-h>', function() require('harpoon.ui').nav_file(1) end, { desc = "Navigate to file 1" })
vim.keymap.set('n', '<C-j>', function() require('harpoon.ui').nav_file(2) end, { desc = "Navigate to file 2" })
vim.keymap.set('n', '<C-k>', function() require('harpoon.ui').nav_file(3) end, { desc = "Navigate to file 3" })
vim.keymap.set('n', '<C-l>', function() require('harpoon.ui').nav_file(4) end, { desc = "Navigate to file 4" })

-- Setup toggleterm
require('toggleterm').setup({
  size = 20,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  persist_size = true,
  direction = 'float',
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = 'curved',
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
})

-- Setup markview
require('markview').setup({
  preview = {
    auto_open = true,
    location = "right",
    width = 35,
    height = 25,
  },
  syntax_highlighting = true,
  features = {
    code_folding = true,
    line_numbers = true,
    syntax_highlight = true,
    smart_wrapping = true,
    auto_highlight_links = true,
    emoji_support = true,
  },
  keymaps = {
    toggle_preview = "<Leader>mp",
    refresh_preview = "<Leader>mr",
    focus_preview = "<Leader>mP",
    close_preview = "<Leader>mc",
  },
  preview_theme = "dark",
})

-- Auto commands
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "python",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "c,cpp",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Check if we're in a small terminal window
    if vim.fn.winwidth(0) < 80 or vim.fn.winheight(0) < 25 then
      return
    end
    
    -- Auto open NvimTree on startup for directory
    local pwd = vim.fn.getcwd()
    if vim.fn.isdirectory(pwd) == 1 then
      local lfs = require('lfs')
      local found_file = false
      for file in lfs.dir(pwd) do
        if file ~= "." and file ~= ".." then
          local attr = lfs.attributes(pwd .. "/" .. file)
          if attr and attr.mode ~= "directory" then
            found_file = true
            break
          end
        end
      end
      
      if not found_file then
        vim.cmd("silent! NvimTreeOpen")
        vim.cmd("wincmd p")
      end
    end
  end,
})

-- Health check function
_G.check_health = function()
  print("=== Neovim Health Check ===")
  print("Neovim version: " .. vim.fn.has('nvim-0.10'))
  print("Treesitter: " .. (pcall(require, 'nvim-treesitter') and "✓ Loaded" or "✗ Not loaded"))
  print("LSP Config: " .. (pcall(require, 'lspconfig') and "✓ Loaded" or "✗ Not loaded"))
  print("Mason: " .. (pcall(require, 'mason') and "✓ Loaded" or "✗ Not loaded"))
end

-- Setup keymap for health check
vim.keymap.set('n', '<leader>ch', function() _G.check_health() end, { desc = "Check Neovim health" })

-- Final message
vim.notify("Neovim configuration loaded successfully!", vim.log.levels.INFO, { title = "Config Loaded" })


