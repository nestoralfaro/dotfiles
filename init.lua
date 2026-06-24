-- ~/.config/nvim/init.lua
-- ttf: JetBrainsMono-NF or Hack NF

-- [[ wsl's clipboard ]]
-- local clip = "/mnt/c/Windows/System32/clip.exe"
--
-- if vim.fn.executable(clip) == 1 then
--   vim.api.nvim_create_augroup("WSLYank", { clear = true })
--
--   vim.api.nvim_create_autocmd("TextYankPost", {
--       group = "WSLYank",
--       pattern = "*",
--       callback = function()
--         local event = vim.v.event
--         if event.operator == "y" and event.regname == "" then
--           local text = table.concat(vim.fn.getreg("0", 1, true), "\n")
--           vim.fn.system(clip, text)
--         end
--       end,
--     })
-- end

--=============================================================================
-- LEADER
--=============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--=============================================================================
-- BOOTSTRAP LAZY.NVIM
--=============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"

  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
    }, true, {})
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

--=============================================================================
-- PLUGINS
--=============================================================================
require("lazy").setup({
  spec = {
    ---------------------------------------------------------------------------
    -- Looks
    ---------------------------------------------------------------------------
    { "Mofiqul/vscode.nvim",                 lazy = false,                                      priority = 1000, }, -- theme
    { "nvim-tree/nvim-web-devicons", },                                                                             -- icons
    { "nvim-lualine/lualine.nvim",           dependencies = { "nvim-tree/nvim-web-devicons", }, },                  -- status line
    { "lukas-reineke/indent-blankline.nvim", main = "ibl",                                      opts = {} },

    ---------------------------------------------------------------------------
    -- LSP Misc
    ---------------------------------------------------------------------------
    { "nvim-telescope/telescope.nvim",       dependencies = { "nvim-lua/plenary.nvim", }, }, -- telescope. Thanks TJ
    { 'nvim-treesitter/nvim-treesitter',     lazy = false,                                      build = ':TSUpdate' },
    { "mason-org/mason.nvim", },
    { "mason-org/mason-lspconfig.nvim", },
    { "neovim/nvim-lspconfig", },                              -- default LSP configs (e.g., with good default options for the langserver like roslyn-language-server --stdio)
    { "saghen/blink.cmp",                    version = "*", }, -- cmp
    { "windwp/nvim-autopairs", },                              -- autopairs
    { "windwp/nvim-ts-autotag", },                             -- auto close HTML/JSX tags
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
      end,
      keys = {
        {
          "<leader>?",
          function() require("which-key").show({ global = false }) end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },
    {
      "olimorris/codecompanion.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
      opts = {
        -- NOTE: The log_level is in `opts.opts`
        opts = {
          log_level = "DEBUG", -- or "TRACE"
        },
      },
    },

    ---------------------------------------------------------------------------
    -- Git
    ---------------------------------------------------------------------------
    { "lewis6991/gitsigns.nvim", },
    { "kdheepak/lazygit.nvim", },
  },

  checker = { enabled = true, },
})

--=============================================================================
-- OPTIONS
--=============================================================================
local opt = vim.opt

opt.relativenumber = true
opt.number = true -- shows absolute line number on cursor line (when relative number is on)
opt.wrap = false
opt.linebreak = false
opt.ignorecase = true   -- can be overriden by prefixing search with \C
opt.smartcase = true    -- assume case-sensitive if search mixes case
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes"  -- show sign column, powered by the LSP and LSP Language Server
opt.cursorline = true   -- highlight current cursor line
opt.swapfile = false    -- adios swapfile
opt.guicursor = "n-v-c-i:block"
opt.scrolloff = 8
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position
opt.tabstop = 2                    -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2                 -- 2 spaces for indent width
opt.expandtab = true               -- expand tab to spaces
opt.autoindent = true              -- copy indent from current line when starting new one
--[[
`:bd! N` where `N` is the annoying buffer with the `+` found with `:ls!` (or even better `:filter /+/ ls!`)
]]
opt.completeopt = { "menu", "menuone", "popup", "fuzzy" }              -- see :h completeopt
vim.cmd([[autocmd BufEnter * set formatoptions-=cro]])                 -- no auto commenting
vim.g.netrw_bufsettings =
"nomodifiable nomed number relativenumber nobuflisted nowrap readonly" -- magical spell for relative line numbers in netrw
opt.clipboard:append("unnamedplus")                                    -- use system clipboard as default register (i.e., adios `"+` or `"*`)
-- auto reload file if modified elsewhere
vim.opt.autoread = true
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
  { command = "checktime" }
)

--=============================================================================
-- PLUGIN Config
--=============================================================================
---------------------------------------------------------------------------
-- Looks
---------------------------------------------------------------------------
-- colorscheme
require("vscode").setup({ transparent = false, })
vim.cmd.colorscheme("vscode")
-- lualine
require("lualine").setup({
  options = {
    theme = "codedark",
    icons_enabled = true,
    globalstatus = true,
  },

  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
-- indent-blankline
require("ibl").setup({
  indent = { char = "│", },
  scope = {
    enabled = true,
    show_start = false,
    show_end = false,
  },
})

---------------------------------------------------------------------------
-- LSP Misc
---------------------------------------------------------------------------
-- BLINK.CMP
require("blink.cmp").setup({
  keymap = { preset = "enter", },
  completion = { documentation = { auto_show = true, }, ghost_text = { enabled = true }, },
  appearance = { nerd_font_variant = "mono", },
  signature = { enabled = true, },
  
})
require("codecompanion").setup({
  adapters = {
    ollama = function()
      -- ollama pull qwen2.5-coder:3b
      return require("codecompanion.adapters").extend("ollama", {
        name = "ollama",
        schema = {
          model = {
            default = "qwen2.5-coder:3b",
          }
        },
      })
    end,
  },

  strategies = {
    chat = {
      adapter = "ollama",
    },
    inline = {
      adapter = "ollama",
    },
    agent = {
      adapter = "ollama",
    },
  },

  opts = {
    log_level = "DEBUG",
  },
})
-- Autoclosing
require("nvim-ts-autotag").setup()
require("nvim-autopairs").setup()
-- Treesitter
require("nvim-treesitter").setup({
  ensure_installed = {
    "c",
    "cpp",
    "c_sharp",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "markdown",
  },

  highlight = { enable = true, },
  indent = { enable = true, },
})
-- TELESCOPE
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fo", telescope.oldfiles, { desc = "Find in recent files" })
vim.keymap.set("n", "<leader>fc", telescope.grep_string, { desc = "Find string under cursor in cwd" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fgc", function() telescope.live_grep({ additional_args = { "--type", "cs" } }) end,
  { desc = "C# grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>fw", telescope.lsp_workspace_symbols, { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>fr", telescope.lsp_references, { desc = "References" })
-- MASON
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",
    "roslyn_ls",
    "lua_ls",
  },
  automatic_installation = true,
})
-- LSP
vim.lsp.enable("clangd")
vim.lsp.enable("roslyn_ls")
vim.lsp.enable("lua_ls")
-- DIAGNOSTICS
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
  severity_sort = true,

  float = {
    border = "rounded",
  },
})

--=============================================================================
-- GITSIGNS
--=============================================================================
require("gitsigns").setup()

--=============================================================================
-- REMAPS
--=============================================================================
local keymap = vim.keymap
keymap.set("n", "Y", "yy", { desc = "Yank line with Y" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "K", ":m '>-2<CR>gv=gv", { desc = "Move selection up" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up without moving cursor" })
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down without moving cursor" })
keymap.set("n", "n", "nzzzv", { desc = "Next search result without moving cursor" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result without moving cursor" })
keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

--=============================================================================
-- BUILT-IN LSP KEYMAPS
--=============================================================================
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
keymap.set("n", "gs", vim.lsp.buf.document_symbol, { desc = "Document symbols" })
keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })
keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols" })
keymap.set("n", "<leader>da", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

--[[######################################################
DEFAULTS (see `:h lsp-defaults`)
#########################################################
-- see gw/gq `:h formatting`

GLOBAL DEFAULTS
                                          *grr* *gra* *grn* *gri* *grt* *i_CTRL-S*
These GLOBAL keymaps are created unconditionally when Nvim starts:
- "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
- "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
- "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
- "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
see: vim.lsp.buf.typehierarchy()
- "grt" is mapped in Normal mode to |vim.lsp.buf.type_definition()|
- "gO" is mapped in Normal mode to ||
- CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|

BUFFER-LOCAL DEFAULTS
- 'omnifunc' is set to |vim.lsp.omnifunc()|, use |i_CTRL-X_CTRL-O| to trigger
  completion.
- 'tagfunc' is set to |vim.lsp.tagfunc()|. This enables features like
  go-to-definition, |:tjump|, and keymaps like |CTRL-]|, |CTRL-W_]|,
  |CTRL-W_}| to utilize the language server.
- 'formatexpr' is set to |vim.lsp.formatexpr()|, so you can format lines via
  |gq| if the language server supports it.
  - To opt out of this use |gw| instead of gq, or clear 'formatexpr' on |LspAttach|.
- |K| is mapped to |vim.lsp.buf.hover()| unless |'keywordprg'| is customized or
  a custom keymap for `K` exists.

DEFAULTS                                              *diagnostic-defaults*
These diagnostic keymaps are created unconditionally when Nvim starts:
- `]d` jumps to the next diagnostic in the buffer. |]d-default|
- `[d` jumps to the previous diagnostic in the buffer. |[d-default|
- `]D` jumps to the last diagnostic in the buffer. |]D-default|
- `[D` jumps to the first diagnostic in the buffer. |[D-default|
- `<C-w>d` shows diagnostic at cursor in a floating window. |CTRL-W_d-default|
]]

--=============================================================================
-- LAZYGIT
--=============================================================================
keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

--=============================================================================
-- STARTUP
--=============================================================================
print("init.lua loaded!")

-- opt.shell = "pwsh.exe" -- sadness
-- -- remember `<leader>nh` stopping at `<leader>n`?
-- opt.timeout = true
-- opt.timeoutlen = 300 -- default is 1000; 300-500 is ideal
-- opt.ttimeoutlen = 50 -- for keycodes
