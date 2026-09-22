-- mappings, including plugins

-- set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(m, k, v, desc) -- helper: mode, key you press, cmd/action
	vim.keymap.set(m, k, v, { noremap = true, silent = true, desc = desc })
end

-- disable space's normal function
map("", "<space>", "<Nop>")

-- ── saving / quitting ────────────────────────────────────────────────────────
map({ "n", "v" }, "<C-s>", "<cmd>write<CR>", "save file")
map("i", "<C-s>", "<cmd>write<CR>", "save file") -- stays in insert, like every other editor
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "clear search highlight")

-- ── buffers & windows ────────────────────────────────────────────────────────
map("n", "<S-l>", ":bnext<CR>", "next buffer")
map("n", "<S-h>", ":bprevious<CR>", "prev buffer")
map("n", "<leader>q", ":bdelete<CR>", "close buffer")
-- everything that can lose work lives behind <leader>b, so a slipped shift key
-- can't turn "open the url under the cursor" into "throw away every buffer"
map("n", "<leader>bn", ":enew<CR>", "new empty buffer")
map("n", "<leader>bd", ":bdelete<CR>", "close buffer")
map("n", "<leader>bD", ":bdelete!<CR>", "close buffer (discard changes)")
map("n", "<leader>bo", ":%bdelete|edit #|bdelete #<CR>", "close other buffers")
map("n", "<leader>bX", ":bufdo bd<CR>", "close all buffers")
map("n", "<leader>vs", ":vsplit<CR>", "vsplit")
map("n", "<leader>w", "<C-w>w", "cycle windows")
map("n", "<leader>W", function() vim.opt.wrap = not vim.opt.wrap:get() end, "toggle wrap")

-- window nav without the <C-w> prefix
map("n", "<C-h>", "<C-w>h", "window left")
map("n", "<C-j>", "<C-w>j", "window down")
map("n", "<C-k>", "<C-w>k", "window up")
map("n", "<C-l>", "<C-w>l", "window right")

-- ── movement quality of life ─────────────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", "half page down, centered")
map("n", "<C-u>", "<C-u>zz", "half page up, centered")
map("n", "n", "nzzzv", "next match, centered")
map("n", "N", "Nzzzv", "prev match, centered")
-- move by screen line when wrapped (matters in prose/notes)
vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ── visual mode ──────────────────────────────────────────────────────────────
map("v", "<", "<gv", "outdent, keep selection")
map("v", ">", ">gv", "indent, keep selection")
map("v", "J", ":m '>+1<CR>gv=gv", "move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "move selection up")
map("x", "p", '"_dP', "paste without clobbering register")

-- ── fzf: find things ─────────────────────────────────────────────────────────
local function fzf(fn, opts)
	return function() require("fzf-lua")[fn](opts) end
end

map("n", "<leader>f", fzf("files"), "find files (cwd)")
map("n", "<leader><leader>", fzf("buffers"), "switch buffer")
map("n", "<leader>g", fzf("live_grep"), "grep (cwd)")
map("n", "<leader>G", fzf("grep_cword"), "grep word under cursor")
map("v", "<leader>g", fzf("grep_visual"), "grep selection")
map("n", "<leader>Fh", fzf("files", { cwd = "~/" }), "find in home")
map("n", "<leader>Fc", fzf("files", { cwd = "~/.config" }), "find in .config")
map("n", "<leader>Fl", fzf("files", { cwd = "~/.local/src" }), "find in .local/src")
map("n", "<leader>Ff", fzf("files", { cwd = ".." }), "find one dir up")
map("n", "<leader>Fr", fzf("resume"), "resume last picker")
map("n", "<leader>Fo", fzf("oldfiles"), "recent files")
map("n", "<leader>Fb", fzf("blines"), "lines in buffer")
map("n", "<leader>Fk", fzf("keymaps"), "keymaps")
map("n", "<leader>?", fzf("keymaps"), "search keymaps")
map("n", "<leader>FH", fzf("helptags"), "help tags")
map("n", "<leader>Fd", fzf("diagnostics_workspace"), "workspace diagnostics")

-- ── git ──────────────────────────────────────────────────────────────────────
map("n", "<leader>T", fzf("git_status"), "git status")
map("n", "<leader>hc", fzf("git_commits"), "git log (repo)")
map("n", "<leader>hf", fzf("git_bcommits"), "git log (file)")

-- ── misc ─────────────────────────────────────────────────────────────────────
map("n", "<leader>t", ":NvimTreeToggle<CR>", "file explorer")
map("n", "<leader>P", ":PlugInstall<CR>", "PlugInstall")

map("n", "<leader>pt", function() --toggle light/dark background
	vim.o.background = vim.o.background == "dark" and "light" or "dark"
end, "toggle light/dark")

map("n", "<leader>u", function() --open url/path under cursor
	vim.ui.open(vim.fn.expand("<cWORD>"))
end, "open url under cursor")

-- no <leader>p: clipboard=unnamedplus means plain `p` already pastes from the
-- system clipboard, and it was shadowing <leader>pt behind timeoutlen
-- ── files: create / rename / move / delete (see config.files) ───────────

local file = function(fn, ...)
	local args = { ... }
	return function() require("config.files")[fn](unpack(args)) end
end

map("n", "<leader>on", file("new"), "new file")
map("n", "<leader>oN", file("new_dir"), "new directory")
map("n", "<leader>or", file("rename"), "rename file")
map("n", "<leader>om", file("move"), "move file")
map("n", "<leader>oc", file("duplicate"), "duplicate file")
map("n", "<leader>oD", file("delete"), "delete file")
map("n", "<leader>oy", file("copy_path", "relative"), "copy relative path")
map("n", "<leader>oY", file("copy_path", "absolute"), "copy absolute path")
map("n", "<leader>ot", file("copy_path", "name"), "copy file name")
map("n", "<leader>od", file("copy_path", "dir"), "copy directory")
map("n", "<leader>ox", file("chmod_x"), "chmod +x")
map("n", "<leader>oe", file("reveal"), "reveal in file tree")
map("n", "<leader>oo", file("open_external"), "open with desktop handler")

map("n", "<leader>z", function() require("config.term").float() end, "floating terminal")
map("n", "<leader>H", function() require("config.term").float("htop") end, "htop")

map("n", "<leader>R", function() --reload config
	for name in pairs(package.loaded) do
		if name:match("^config") or name:match("^plugins") then
			package.loaded[name] = nil
		end
	end
	dofile(vim.env.MYVIMRC)
	vim.notify("config reloaded")
end, "reload config")

-- ── notes (plain markdown vault, see config.notes) ───────────────────────────
local notes = function(fn)
	return function() require("config.notes")[fn]() end
end

map("n", "<leader>nf", notes("find"), "find note")
map("n", "<leader>ng", notes("grep"), "grep notes")
map("n", "<leader>nd", notes("daily"), "today's daily note")
map("n", "<leader>ny", notes("yesterday"), "yesterday's daily note")
map("n", "<leader>nw", notes("new"), "new note")
map("n", "<leader>ni", notes("index"), "notes index")
map("n", "<leader>nl", notes("link"), "insert link to note")
map("n", "<leader>nt", notes("todos"), "open TODOs across notes")
map("n", "<leader>nb", notes("backlinks"), "backlinks to this note")
map("n", "<leader>nc", notes("toggle_checkbox"), "toggle checkbox")

map("n", "<leader>N", function() --toggle relative numbers (overrides the dynamic auto-toggle in config.autocmd)
	vim.g.dynamic_relnum = not vim.g.dynamic_relnum
	vim.opt.relativenumber = vim.g.dynamic_relnum
end, "toggle relative numbers")
