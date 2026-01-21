-- ~/.config/nvim/init.lua
-- -- Modern Neovim config with Lazy.nvim, Pyrefly, Mason, and fixed LSP setup

-- Set leader key before anything else
vim.g.mapleader = ' '
vim.g.localleader = ' '

-- Options
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

-- Clipboard Mappings (Explicit copy/paste to system clipboard)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
vim.keymap.set("x", "<leader>P", [["_dP]], { desc = "Paste over selection without clobbering" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole register" })

-- Diagnostics Config
vim.diagnostic.config({
  virtual_text = false, -- Disable inline text (fixes text going off screen)
  signs = true,         -- Keep signs in the gutter (like gitsigns)
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

-- Auto-show diagnostics in a floating window on hover
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
  end
})

-- Disable Netrw (Required for Nvim-Tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Specifications
require("lazy").setup({
  -- Core plugins
  { "nvim-lua/plenary.nvim" },

  -- UI & Appearance
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Custom key mappings for nvim-tree
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Load default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- Custom Mappings
        vim.keymap.set('n', 'ss', api.tree.close, opts('Close')) -- 'ss' to close
        vim.keymap.del('n', 's', { buffer = bufnr }) -- Unmap 's' to prevent conflict/accidents
      end

      require("nvim-tree").setup({
        on_attach = on_attach,
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
      })
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
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
      })
    end
  },

  -- Color schemes
  { "Mofiqul/vscode.nvim" },
  { "agude/vim-eldar" },
  { "navarasu/onedark.nvim" },
  { "neanias/everforest-nvim" },
  { "oonamo/ef-themes.nvim" },
  { "alexxGmZ/e-ink.nvim" },
  {
    "gruvbox-community/gruvbox",
    priority = 1000,
    config = function()
      vim.cmd('colorscheme gruvbox')
      vim.cmd('set background=dark')
    end
  },

  -- Autopairs (Auto close brackets)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- Comments (Easy commenting with gc)
  {
    "numToStr/Comment.nvim",
    config = true
  },

  -- Indent Guides (Vertical lines)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- Which-Key (Keybinding helper)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
          file_ignore_patterns = { "node_modules", "%.git", "%.cache" },
          preview = { treescope = true },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help Tags" })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    cmd = "TSUpdate",
    opts = {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "cpp", "javascript", "typescript" },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- LSP, Mason, Completion
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require('mason').setup()

      _G.lsp_keymaps = function(bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- Navigation
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

        -- Actions
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)

        -- Diagnostics
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      end

      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      local configs = require('lspconfig.configs')
      if not configs.ty then
        configs.ty = {
          default_config = {
            cmd = { "ty", "lsp" },
            root_dir = require('lspconfig.util').root_pattern("pyproject.toml", "setup.py", ".git"),
            filetypes = { "python" },
          },
        }
      end

      require('mason-lspconfig').setup({
        ensure_installed = { 'ty', 'pyrefly', 'clangd', 'ts_ls', 'lua_ls' },
        handlers = {
          function(server_name)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig')[server_name].setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr) _G.lsp_keymaps(bufnr) end,
            })
          end,
          ['ty'] = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig').ty.setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr) _G.lsp_keymaps(bufnr) end,
            })
          end,
          ['pyrefly'] = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig').pyrefly.setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr) _G.lsp_keymaps(bufnr) end,
            })
          end,
          ['lua_ls'] = function()
            require('lspconfig').lua_ls.setup({
              settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
              on_attach = function(client, bufnr) _G.lsp_keymaps(bufnr) end,
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })
          end,
        }
      })
    end
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
        },
        current_line_blame = true, -- Enable inline blame
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 300, -- Faster update (was 1000)
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
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
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('n', '<leader>hp', gs.preview_hunk)
        end,
      })
    end
  },

  -- Navigation & Productivity
  {
    "ThePrimeagen/harpoon",
    config = function()
      require('harpoon').setup()
      vim.keymap.set('n', '<leader>ha', function() require('harpoon.mark').add_file() end, { desc = "Harpoon: Add file" })
      vim.keymap.set('n', '<leader>hm', function() require('harpoon.ui').toggle_quick_menu() end)
      vim.keymap.set('n', '<C-h>', function() require('harpoon.ui').nav_file(1) end)
      vim.keymap.set('n', '<C-j>', function() require('harpoon.ui').nav_file(2) end)
      vim.keymap.set('n', '<C-k>', function() require('harpoon.ui').nav_file(3) end)
      vim.keymap.set('n', '<C-l>', function() require('harpoon.ui').nav_file(4) end)
    end
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = 'float',
        shade_terminals = true
      })
    end
  },

  -- Markdown Preview
  {
    "OXY2DEV/markview.nvim",
    config = function()
      require('markview').setup({
        preview = {
          auto_open = true,
          location = "right",
          width = 35,
        },
        keymaps = {
          toggle_preview = "<Leader>mp",
        },
        preview_theme = "dark",
      })
    end
  },

  -- Extra utilities
  { "nvzone/typr" },
  { "nvzone/volt" },

  -- Flash (Fast navigation)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Trouble (Better diagnostics list)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
    },
  },

  -- Todo Comments (Highlight & Search TODOs)
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    }
  },
})

-- Global Keymaps
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ss', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })

-- Auto commands
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "python,c,cpp",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

vim.notify("Neovim configuration upgraded!", vim.log.levels.INFO)
