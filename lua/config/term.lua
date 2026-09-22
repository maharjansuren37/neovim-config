-- minimal floating terminal, no plugin needed
-- toggles: the shell keeps running (and keeps its scrollback and cwd) between opens

local M = {}

local terms = {} -- key -> { buf, win }

local function open_win(buf)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	return vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})
end

-- toggle the terminal identified by `cmd` (nil = the shell)
function M.float(cmd)
	local key = cmd or "$SHELL"
	local t = terms[key]

	-- already visible -> hide it, leaving the job running
	if t and t.win and vim.api.nvim_win_is_valid(t.win) then
		vim.api.nvim_win_close(t.win, false)
		t.win = nil
		return
	end

	-- buffer still alive -> just show it again
	if t and vim.api.nvim_buf_is_valid(t.buf) then
		t.win = open_win(t.buf)
		vim.cmd.startinsert()
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	t = { buf = buf }
	terms[key] = t
	t.win = open_win(buf)

	vim.fn.jobstart(cmd or vim.o.shell, {
		term = true,
		cwd = vim.fn.getcwd(),
		on_exit = function()
			terms[key] = nil
			if t.win and vim.api.nvim_win_is_valid(t.win) then
				vim.api.nvim_win_close(t.win, true)
			end
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end,
	})
	vim.cmd.startinsert()

	-- <C-q> hides the float. In the shell <Esc> is deliberately left alone: mapping
	-- it breaks every program you'd actually run in there (vim, less, fzf, ssh).
	-- <C-\><C-n> still gets you to normal mode inside the terminal.
	vim.keymap.set({ "t", "n" }, "<C-q>", function() M.float(cmd) end, { buffer = buf, silent = true })
	-- single-tool floats (htop, ...) don't need <Esc> themselves, so let it hide them
	if cmd then
		vim.keymap.set({ "t", "n" }, "<Esc>", function() M.float(cmd) end, { buffer = buf, silent = true })
	end
end

return M
