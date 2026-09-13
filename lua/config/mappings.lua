-- mappings, including plugins

-- set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(m, k, v) -- helper function for mode, key you press, cmd/action
    vim.keymap.set(m, k, v, { noremap = true, silent = true })
end

-- disable space's normal function
map("", "<space>", "<Nop>")

map("n", "<leader>cd", vim.cmd.Ex)

-- buffers
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")
map("n", "<leader>q", ":bdelete<CR>")
map("n", "<leader>Q", ":bdelete!<CR>")
map("n", "<leader>U", ":bufdo bd<CR>") --close all
map("n", "<leader>vs", ":vsplit<CR>:bnext<CR>") --ver split + open next buffer
map("n", "<leader>w", "<C-w>w")
map("n", "<leader>W", function() vim.opt.wrap = not vim.opt.wrap:get() end) --toggle wrap

-- fzf and grep
map("n", "<leader>f", ":lua require('fzf-lua').files()<CR>") --search cwd
map("n", "<leader>Fh", ":lua require('fzf-lua').files({ cwd = '~/' })<CR>") --search home
map("n", "<leader>Fc", ":lua require('fzf-lua').files({ cwd = '~/.config' })<CR>") --search .config
map("n", "<leader>Fl", ":lua require('fzf-lua').files({ cwd = '~/.local/src' })<CR>") --search .local/src
map("n", "<leader>Ff", ":lua require('fzf-lua').files({ cwd = '..' })<CR>") --search above
map("n", "<leader>Fr", ":lua require('fzf-lua').resume()<CR>") --last search
map("n", "<leader>g", ":lua require('fzf-lua').grep()<CR>") --grep
map("n", "<leader>G", ":lua require('fzf-lua').grep_cword()<CR>") --grep word under cursor

-- misc
map("n", "<leader>t", ":NvimTreeToggle<CR>") --open file explorer
map("n", "<leader>P", ":PlugInstall<CR>") --vim-plug

map("n", "<leader>p", function() --toggle light/dark background
	vim.o.background = vim.o.background == "dark" and "light" or "dark"
end)

map("n", "<leader>u", function() --open url/path under cursor
	vim.ui.open(vim.fn.expand("<cWORD>"))
end)

map("n", "<leader>z", function() require("config.term").float() end) --floating terminal
map("n", "<leader>H", function() require("config.term").float("htop") end) --htop terminal

map("n", "<leader>x", function() --chmod +x current file
	local f = vim.fn.expand("%:p")
	if f ~= "" then
		vim.fn.system({ "chmod", "+x", f })
	end
end)

map("n", "<leader>d", function() --duplicate current file
	local src = vim.fn.expand("%:p")
	if src == "" then
		return
	end
	local dir = vim.fn.expand("%:p:h")
	local name = vim.fn.expand("%:t:r")
	local ext = vim.fn.expand("%:e")
	local suffix = ext ~= "" and ("." .. ext) or ""
	local dest = dir .. "/" .. name .. "-copy" .. suffix
	local i = 1
	while vim.fn.filereadable(dest) == 1 do
		dest = dir .. "/" .. name .. "-copy" .. i .. suffix
		i = i + 1
	end
	vim.fn.writefile(vim.fn.readfile(src), dest)
	vim.cmd.edit(vim.fn.fnameescape(dest))
end)

map("n", "<leader>R", function() --reload config
	for name in pairs(package.loaded) do
		if name:match("^config") or name:match("^plugins") then
			package.loaded[name] = nil
		end
	end
	dofile(vim.env.MYVIMRC)
end)

-- notes (plain markdown in ~/notes, see config.notes)
map("n", "<leader>nf", function() require("config.notes").find() end) --find note
map("n", "<leader>ng", function() require("config.notes").grep() end) --grep notes
map("n", "<leader>nd", function() require("config.notes").daily() end) --today's daily note
map("n", "<leader>nw", function() require("config.notes").new() end) --new note

-- git
map("n", "<leader>T", function() require("fzf-lua").git_status() end) --git status

map("n", "<leader>nn", function() --toggle relative numbers (overrides dynamic auto-toggle in config.autocmd)
	vim.g.dynamic_relnum = not vim.g.dynamic_relnum
	vim.opt.relativenumber = vim.g.dynamic_relnum
end)
