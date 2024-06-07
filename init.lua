--[[
**************************************************************
                          plugins
**************************************************************
--]]
-- ********************** install *******************************
function prequire(name, setup)
  local status, plugin = pcall(require, name)
  if not status then
    print("failed to load " .. name)
    return
  end
  if setup == nil then
    setup = {}
  end
  plugin.setup(setup)
end
-- auto install packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed
-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
-- vim.cmd([[ 
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost init.lua source <afile> | PackerSync
--   augroup end
-- ]])
-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
  print("packer")
  return
end
-- plugins to install
packer.startup(function(use)
	use("wbthomason/packer.nvim")-- packer
	use("Mofiqul/vscode.nvim") -- vscode theme
	use("numToStr/Comment.nvim") -- commenting with gc
	use("kyazdani42/nvim-web-devicons") -- icons
	use ("nvim-lualine/lualine.nvim") -- status line
	-- telescope (fuzzy finder)
	use { 'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		requires = { {'nvim-lua/plenary.nvim'} }
	}
	-- treesitter
	use{ 'nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' }, }
	-- lsp
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v1.x',
		requires = {
		-- LSP Support
		{'neovim/nvim-lspconfig'},
		{'williamboman/mason.nvim'},
		{'williamboman/mason-lspconfig.nvim'},
		-- Autocompletion
		{'hrsh7th/nvim-cmp'},
		{'hrsh7th/cmp-buffer'},
		{'hrsh7th/cmp-path'},
		{'saadparwaiz1/cmp_luasnip'},
		{'hrsh7th/cmp-nvim-lsp'},
		{'hrsh7th/cmp-nvim-lua'},
		-- Snippets
		{'L3MON4D3/LuaSnip'},
		{'rafamadriz/friendly-snippets'},
		}
	}
	-- auto closing
	use("windwp/nvim-autopairs") -- autoclose parens, brackets, quotes, etc...
	use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags
	-- git
	use("tpope/vim-fugitive")
	use("lewis6991/gitsigns.nvim")
	-- indent blank line
	use("lukas-reineke/indent-blankline.nvim")
	-- required per documentation
	if packer_bootstrap then
		require("packer").sync()
	end
end)

-- ********************** config *******************************
prequire("Comment")
prequire("lualine", { options = { theme = "codedark" } } )
local status, _ = pcall(vim.cmd, "colorscheme vscode")
if not status then
  print("vscode colorscheme not found.")
  return
end
-- telescope
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
  print("telescope.actions")
  return
end
prequire("telescope", {
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
        ["<C-j>"] = actions.move_selection_next, -- move to next result
        -- ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
      },
    },
  },
})
-- treesitter
local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
  print("nvim-treesitter.configs")
  return
end
treesitter.setup({
  -- enable syntax highlighting
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  -- enable indentation
  indent = { enable = true },
  -- enable autotagging (w/ nvim-ts-autotag plugin)
  autotag = { enable = true },
  -- ensure these language parsers are installed
  ensure_installed = {
    "c",
    "c_sharp",
    "json",
    "javascript",
    "typescript",
    "tsx",
    "yaml",
    "html",
    "css",
    "markdown",
    "markdown_inline",
    "bash",
    "lua",
    "vim",
    "vimdoc",
    "dockerfile",
    "gitignore",
  },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
})
-- nvim-cmp
local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
  print("cmp")
  return
end
local luasnip_status, luasnip = pcall(require, "luasnip")
if not luasnip_status then
  print("luasnip")
  return
end
-- load vs-code like snippets from plugins (e.g. friendly-snippets)
require("luasnip/loaders/from_vscode").lazy_load()
vim.opt.completeopt = "menu,menuone,noselect"
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
    ["<C-e>"] = cmp.mapping.abort(), -- close completion window
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  -- sources for autocompletion
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- lsp
    { name = "luasnip" }, -- snippets
    { name = "buffer" }, -- text within current buffer
    { name = "path" }, -- file system paths
  }),
})
-- lsp
local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
})
-- Fix Undefined global 'vim'
lsp.nvim_workspace()
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil
lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "<C-k>", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "K", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)
lsp.setup()

-- autopairs
local autopairs_setup, autopairs = pcall(require, "nvim-autopairs")
if not autopairs_setup then
  print("nvim-autopairs")
  return
end
autopairs.setup({
  check_ts = true, -- enable treesitter
  ts_config = {
    lua = { "string" }, -- don't add pairs in lua string treesitter nodes
    javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
    java = false, -- don't check treesitter on java
  },
})
local cmp_autopairs_setup, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
if not cmp_autopairs_setup then
  print("nvim-autopairs.completion.cmp")
  return
end
-- make autopairs and completion work together
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
prequire("gitsigns")
prequire("ibl")

--[[
**************************************************************
				options
**************************************************************
--]]
local opt = vim.opt
opt.guicursor = "n-v-c-i:block"
-- vim.opt.formatoptions:remove{"c", "r", "o"} -- this only works when `:so`. However, it gets overwritten by C file plugin in Vim (WHY? idk)
vim.cmd([[autocmd BufEnter * set formatoptions-=cro]]) -- no auto commenting EVER AGAIN
-- line numbers
opt.relativenumber = true
opt.number = true
opt.swapfile = false

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false
opt.linebreak = false

-- search settings
opt.ignorecase = true
opt.smartcase = true
-- opt.hlsearch = false
opt.incsearch = true

opt.scrolloff = 8

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")
vim.g.netrw_liststyle = 3;
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  float = {
    show_header = true,
    source = "always",
    border = "rounded",
    focusable = true
  }
})

--[[
**************************************************************
                          keymaps
**************************************************************
--]]
local keymap = vim.keymap
vim.g.mapleader = " "
------------------------
-- General Keymaps
------------------------
-- Yanking keymap
keymap.set("n", "Y", "yy")
keymap.set("n", "*", "*``")

-- navigation
keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- move visual line downwards
keymap.set("v", "K", ":m '>-2<CR>gv=gv") -- move visual line upwards
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- replace selected word
-- keymap.set("n", "<leader>e", ":w<CR>:Ex<CR>")
keymap.set("n", "<leader>e", function()
  if vim.bo.modified then
    vim.cmd(":w")
  end
  vim.cmd(":bd!")
  vim.cmd(":Ex")
end)

keymap.set("n", "J", "mzJ`z") -- J appends next line while keeping cursor in place
keymap.set("n", "<C-u>", "<C-u>zz") -- half page jumping without moving cursor
keymap.set("n", "<C-d>", "<C-d>zz") -- half page jumping without moving cursor
keymap.set("n", "n", "nzzzv") -- next search without moving cursor
keymap.set("n", "N", "Nzzzv") -- previous search without moving cursor

-- loading to void register
keymap.set("x", "<leader>p", "\"_dP")
keymap.set("n", "<leader>d", "\"_d")
keymap.set("v", "<leader>d", "\"_d")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window
-- tab management
keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tl", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>th", ":tabp<CR>") --  go to previous tab

------------------------
-- Plugins Keymaps
------------------------
-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags
keymap.set("n", "K", function() vim.diagnostic.open_float() end, opts)

-- git
keymap.set("n", "<leader>gs", vim.cmd.Git)
print("should be good!")
