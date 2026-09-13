-- minimal floating terminal, no plugin needed

local M = {}

function M.float(cmd)
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.fn.jobstart(cmd or vim.o.shell, { term = true })
	vim.cmd.startinsert()

	vim.keymap.set("t", "<Esc>", [[<C-\><C-n>:close<CR>]], { buffer = buf, silent = true })
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = buf,
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(0) then
				vim.cmd.close()
			end
		end,
	})
end

return M
