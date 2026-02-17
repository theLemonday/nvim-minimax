-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = Config.now_if_args
local now = MiniDeps.now

-- Colorscheme
vim.opt.termguicolors = true

add({ source = 'RRethy/base16-nvim' })
now(function()
  local theme = vim.env.LIGHT_THEME
  if vim.fn.executable('darkman') == 1 then
    local out = vim.system({ 'darkman', 'get' }, { text = true }):wait().stdout
    if out and vim.trim(out) == 'dark' then theme = vim.env.DARK_THEME end
  end
  vim.cmd('colorscheme base16-' .. theme)
end)

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    -- 2. Add and Setup the plugin ONLY when a Lua file is opened
    add({
      source = 'folke/lazydev.nvim',
    })

    -- 3. Configure it immediately for this buffer
    require('lazydev').setup({
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    })
  end,
  once = true, -- Important: Only run this once per session to avoid re-adding
})
-- Blink.cmp
add({
  source = 'saghen/blink.cmp',
  depends = { 'saghen/blink.compat', 'rafamadriz/friendly-snippets' },
  checkout = 'v1.9.1', -- check releases for latest tag
})

require('blink.cmp').setup({
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  --
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = {
    preset = 'default',
    ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
    ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
    ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
    ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
    ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
    ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
    ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
    ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
    ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
    ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
  },
  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  -- Default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = {
      'lsp',
      'path',
      'snippets',
      'buffer',
    },
    providers = {
      go_deep = {
        name = 'go_deep',
        module = 'blink.compat.source',
        min_keyword_length = 3,
        max_items = 5,
        ---@module "cmp_go_deep"
        ---@type cmp_go_deep.Options
        opts = {
          -- See below for configuration options
        },
      },
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        -- make lazydev completions top priority (see `:h blink.cmp`)
        score_offset = 100,
      },
    },
  },

  completion = {
    ghost_text = { enabled = true },
    menu = {
      draw = {
        columns = {
          { 'item_idx' },
          -- { "kind_icon" },
          { 'label', 'label_description', gap = 1 },
          { 'kind' },
        },
        components = {
          item_idx = {
            text = function(ctx) return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx) end,
            highlight = 'BlinkCmpItemIdx', -- optional, only if you want to change its color
          },
          kind_icon = {
            text = function(ctx)
              local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
              return kind_icon
            end,
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          },
          kind = {
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          },
        },
      },
    },
    documentation = {
      auto_show = false,
    },
  },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Update tree-sitter parser after plugin is updated
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    -- Use `main` branch since `master` branch is frozen, yet still default
    -- It is needed for compatibility with 'nvim-treesitter' `main` branch
    checkout = 'main',
  })

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
    'go',
    'python',
    'yaml',
    'json',
    'bash',
    'zsh',
    'toml',
    'html',
    'javascript',
    'vue',
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  }
  local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add({
    source = 'cenk1cenk2/schema-companion.nvim',
    depends = { 'nvim-lua/plenary.nvim' },
  })
  require('schema-companion').setup({
    log_level = vim.log.levels.INFO,
  })

  add({ source = 'b0o/schemastore.nvim' })
  add({ source = 'neovim/nvim-lspconfig' })

  vim.lsp.config('*', {
    root_markers = { '.git' },
  })

  vim.lsp.enable({
    'ty',
    'dockerls',
    'gopls',
    'jsonls',
    'lua_ls',
    'nil_ls',
    'yamlls',
    'ruff',
  })

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
  -- vim.lsp.enable({
  --   -- For example, if `lua-language-server` is installed, use `'lua_ls'` entry
  -- })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add('stevearc/conform.nvim')

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
    },
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    formatters_by_ft = {
      lua = { 'stylua' },
      dockerfile = { 'dockerfmt' },
      go = { 'goimports', 'gofumpt', 'golines' },
      python = {
        'ruff_organize_imports',
        -- To fix lint errors.
        'ruff_fix',
        -- To run the Ruff formatter.
        'ruff_format',
      },
      nix = { 'nixpkgs_fmt' },
      javascript = { 'prettierd' },
      typescript = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      vue = { 'prettierd' },
      bash = { 'shfmt' },
      yaml = { 'yamlfix' },
      json = { 'prettierd' },
      jsonc = { 'prettierd' },
      markdown = { 'prettierd' },
    },
    format_on_save = function(bufnr)
      local max_lines = 5000
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      if line_count > max_lines then
        return -- Do not format this buffer
      end
      return { timeout_ms = 2000, lsp_fallback = true }
    end,
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add('rafamadriz/friendly-snippets') end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- now_if_args(function()
--   add('mason-org/mason.nvim')
--   require('mason').setup()
-- end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- MiniDeps.now(function()
--   -- Install only those that you need
--   add('sainnhe/everforest')
--   add('Shatur/neovim-ayu')
--   add('ellisonleao/gruvbox.nvim')
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)

now(function()
  add({
    source = 'm4xshen/hardtime.nvim',
    depends = { 'MunifTanjim/nui.nvim' }, -- explicit dependency handling
  })
  require('hardtime').setup({})
end)

-- 2. Grug-far.nvim (Safe to defer with 'later')
later(function()
  add({
    source = 'MagicDuck/grug-far.nvim',
  })

  -- The setup call
  require('grug-far').setup({
    -- options go here
  })
end)
