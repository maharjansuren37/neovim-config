
local data_dir = vim.fn.stdpath('data')

if vim.fn.empty(vim.fn.glob(data_dir .. '/site/autoload/plug.vim')) == 1 then
    vim.cmd('silent !curl -fLo ' .. data_dir .. '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')

    vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

local vim = vim
local Plug = vim.fn['plug#']

vim.g.start_time = vim.fn.reltime()
vim.loader.enable() --  SPEEEEEEEEEEED 
vim.call('plug#begin')

Plug('folke/which-key.nvim') --mappings popup
Plug('ibhagwan/fzf-lua') --fuzzy finder and grep
Plug('nvim-treesitter/nvim-treesitter') --improved syntax
Plug('nvim-tree/nvim-tree.lua') --file explorer
Plug('MeanderingProgrammer/render-markdown.nvim') --render md inline
Plug('lewis6991/gitsigns.nvim') --git gutter signs + hunk stage/reset/blame
Plug('neovim/nvim-lspconfig') --default LSP server configs (native vim.lsp.enable, no mason)
Plug('saghen/blink.cmp', { tag = '*' }) --completion, prebuilt binary, no cargo needed (latest tag)
Plug('stevearc/conform.nvim') --formatting
Plug('mfussenegger/nvim-lint') --linting (used by config.autocmd BufWritePost)

vim.call('plug#end')

-- initialize core settings first
require("config.options")
require("config.mappings")

-- plugins
require("plugins.fzf-lua")
require("plugins.treesitter")
require("plugins.nvim-tree")
require("plugins.render-markdown")
require("plugins.gitsigns")
require("plugins.blink")
require("plugins.lsp")
require("plugins.conform")
require("plugins.lint")
require("plugins.which-key")
