local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug('nvim-tree/nvim-tree.lua') --file explorer

vim.call('plug#end')	


require("config.options")
require("config.keybinds")
require("nvim-tree").setup()
