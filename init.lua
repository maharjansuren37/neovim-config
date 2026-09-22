
local data_dir = vim.fn.stdpath('data')
local bootstrap = vim.fn.empty(vim.fn.glob(data_dir .. '/site/autoload/plug.vim')) == 1

if bootstrap then
    vim.cmd('silent !curl -fLo ' .. data_dir .. '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
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

-- first run: nothing is installed yet, so requiring the plugin modules below
-- would only produce a wall of "module not found". Install, then re-source.
if bootstrap then
    vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        command = 'PlugInstall --sync | source $MYVIMRC',
    })
    return
end

-- initialize core settings first
require("config.options")
require("config.mappings")
require("config.autocmd")

-- plugins. pcall so one broken plugin doesn't take the rest of the config
-- (and its mappings) down with it
for _, mod in ipairs({
    "plugins.fzf-lua",
    "plugins.treesitter",
    "plugins.nvim-tree",
    "plugins.render-markdown",
    "plugins.gitsigns",
    "plugins.blink",
    "plugins.lsp",
    "plugins.conform",
    "plugins.lint",
    "plugins.which-key",
}) do
    local ok, e = pcall(require, mod)
    if not ok then
        vim.notify(mod .. ': ' .. tostring(e), vim.log.levels.WARN)
    end
end
