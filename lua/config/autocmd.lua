--useful stuff

-- close nvim-tree if it's last buffer open
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		if #vim.api.nvim_list_bufs() == 1 and vim.bo.filetype == "NvimTree" then
	vim.cmd("quit")
	end
	end,
})


-- auto-create missing dirs when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		if args.match:match("^%w+://") then
			return
		end
		local dir = vim.fn.fnamemodify(args.match, ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})


-- linting when file is written to
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype, on write
    require("lint").try_lint()
  end,
})


-- markdown / notes writing setup
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit" },
	callback = function(args)
		vim.opt_local.spell = true
		vim.opt_local.wrap = true
		vim.opt_local.conceallevel = 2
		vim.opt_local.shiftwidth = 2 -- markdown lists nest in 2s
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		-- lists continue on <CR> / o, like every other note app
		vim.opt_local.formatoptions:append("n")
		vim.opt_local.comments = "b:- [ ],b:- [x],b:-,b:*,b:>"

		local function bmap(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
		end

		-- <CR> follows a [[wikilink]], falls through to a normal <CR> otherwise
		bmap("n", "<CR>", function()
			if not require("config.notes").follow_link() then
				vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
			end
		end, "follow wikilink")
		bmap("i", "<C-l>", function() require("config.notes").link() end, "insert note link")
	end,
})

-- autosave notes: a note app you have to remember to :w is a worse note app.
-- deliberately no TextChanged: it fires on nearly every edit, and each write
-- runs format-on-save + lint, which reflows the note under the cursor
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
	pattern = "*.md",
	callback = function(args)
		local vault = vim.fn.expand("~/para/02-areas/hnoteverse")
		if not vim.startswith(vim.fn.fnamemodify(args.file, ":p"), vault) then
			return
		end
		if vim.bo[args.buf].modifiable and vim.bo[args.buf].modified and vim.bo[args.buf].buftype == "" then
			vim.api.nvim_buf_call(args.buf, function() vim.cmd("silent! write") end)
		end
	end,
})


-- disable automatic comment on newline
vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
		end,
})


-- highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
	vim.hl.on_yank({ timeout = 300 })
	end,
})


-- reload files changed outside nvim (git checkout, formatter, other editor)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter" }, {
	pattern = "*",
	command = "checktime",
})


-- restore cursor pos on file open
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
	local line = vim.fn.line("'\"")
	if line > 1 and line <= vim.fn.line("$") then
		vim.cmd("normal! g'\"")
	end
end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local startuptime = vim.fn.reltimefloat(vim.fn.reltime(vim.g.start_time))
    vim.g.startup_time_ms = string.format("%.2f ms", startuptime * 1000)
  end,
})

-- relative numbers only while the window is active; <leader>N (mappings.lua)
-- disables this dynamic behavior entirely instead of fighting it
vim.g.dynamic_relnum = true
local relnum_augroup = vim.api.nvim_create_augroup("dynamic_relativenumber", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
   pattern = "*",
   group = relnum_augroup,
   callback = function()
      if vim.g.dynamic_relnum and vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
         vim.opt.relativenumber = true
      end
   end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
   pattern = "*",
   group = relnum_augroup,
   callback = function()
      if vim.g.dynamic_relnum and vim.o.nu then
         vim.opt.relativenumber = false
         -- Conditional taken from https://github.com/rockyzhang24/dotfiles/commit/03dd14b5d43f812661b88c4660c03d714132abcf
         -- Workaround for https://github.com/neovim/neovim/issues/32068
         if not vim.tbl_contains({"@", "-"}, vim.v.event.cmdtype) then
            vim.cmd "redraw"
         end
      end
   end,
})


-- terminal buffers: no numbers, straight into insert
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- q closes throwaway windows instead of :q
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "query" },
	callback = function(args)
		vim.bo[args.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
		vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = args.buf, silent = true })
	end,
})

-- <Esc> closes a focused float (LSP hover / diagnostics after pressing K twice);
-- terminal floats are skipped, config.term handles those
vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if vim.api.nvim_win_get_config(0).relative == "" or vim.bo.buftype == "terminal" then
			return
		end
		vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = true, silent = true })
	end,
})

-- open help in a vertical split; reading docs beside code beats a squat window
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	callback = function()
		vim.cmd("wincmd L")
	end,
})
