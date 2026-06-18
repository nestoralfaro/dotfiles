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

--[[
--======================================== Remaps  ========================================
--]]
vim.g.mapleader = " "
local keymap = vim.keymap

keymap.set("n", "Y", "yy", { desc = "Yank line with Y" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move visual line downwards"} )
keymap.set("v", "K", ":m '>-2<CR>gv=gv", { desc = "Move visual line upwards" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page jumping without moving cursor" })
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page jumping without moving cursor" })
keymap.set("n", "n", "nzzzv", { desc = "Next search without moving cursor" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search without moving cursor" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

--[[ Force-reload lsp: Stop all clients, then reload the buffer.
 :lua vim.lsp.stop_client(vim.lsp.get_clients())
 :edit
]]

vim.keymap.set("n","gd", vim.lsp.buf.definition, { desc = "Go to definition." });
vim.keymap.set("n","gs", vim.lsp.buf.document_symbol, { desc = "List symbols." });
vim.keymap.set("n","<leader>da", vim.diagnostic.setqflist, { desc = "Show all diagnostics in the quickfix list." });
-- see: vim.lsp.buf.workspace_symbol()
-- see gw/gq `:h formatting`

--[[ defaults (see `:h lsp-defaults`)
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
--[[
======================================== Options  ========================================
]]
local opt = vim.opt

opt.relativenumber = true
opt.number = true -- shows absolute line number on cursor line (when relative number is on)
opt.wrap = false
opt.linebreak = false
opt.ignorecase = true -- can be overriden by prefixing search with \C
opt.smartcase = true -- assume case-sensitive if search mixes case
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column, powered by the LSP and LSP Language Server
opt.cursorline = true -- highlight current cursor line
opt.swapfile = false -- adios swapfile
opt.guicursor = "n-v-c-i:block"
opt.scrolloff = 8
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position
-- opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
-- opt.expandtab = true -- expand tab to spaces
-- opt.autoindent = true -- copy indent from current line when starting new one
--[[
This `vim.opt.hidden=true` supposedly fixes the error below?
Error detected while processing function <SNR>51_NetrwBrowseChgDir[163]..<SNR>51_NetrwEditFile: line 10: E37: No write since last change (add ! to override)
`:bd! N` where `N` is the annoying buffer with the `+` found with `:ls!` (or even better `:filter /+/ ls!`)
--]]
opt.hidden = true
opt.completeopt = { "menu", "menuone","popup", "fuzzy" } -- see :h completeopt
vim.cmd([[autocmd BufEnter * set formatoptions-=cro]]) -- no auto commenting
vim.g.netrw_bufsettings="nomodifiable nomed number relativenumber nobuflisted nowrap readonly" -- magical spell for relative line numbers in netrw
opt.clipboard:append("unnamedplus") -- use system clipboard as default register (i.e., adios `"+` or `"*`)
vim.treesitter.start = function() end -- adios treesitter
--[[
mkdir -p ~/.local/share/nvim/site/pack/themes/start
cd ~/.local/share/nvim/site/pack/themes/start
git clone https://github.com/tomasiser/vim-code-dark
]]
vim.cmd.colorscheme("codedark")

--[[
======================================== LSP  ========================================
]]
local function lsp(name, cmd, filetypes)
  vim.lsp.config[name] = { cmd = cmd, filetypes = filetypes }
  vim.lsp.enable(name)
end

lsp("clangd", { "clangd" }, { "c", "cc", "cpp", "h", "hh", "hpp" })

print("should be good!")


-- opt.shell = "pwsh.exe" -- sadness
-- -- remember `<leader>nh` stopping at `<leader>n`?
-- opt.timeout = true
-- opt.timeoutlen = 300 -- default is 1000; 300-500 is ideal
-- opt.ttimeoutlen = 50 -- for keycodes
