-- lightweight note-taking: plain markdown files in the notes vault, no plugin needed
-- reuses fzf-lua for find/grep and render-markdown + the existing
-- FileType markdown autocmd (spell+wrap) for viewing

local M = {}

M.dir = vim.fn.expand("~/para/02-areas/hnoteverse")
local daily_dir = M.dir .. "/daily"

local function ensure_dirs()
	vim.fn.mkdir(daily_dir, "p")
end

function M.find()
	ensure_dirs()
	require("fzf-lua").files({ cwd = M.dir })
end

function M.grep()
	ensure_dirs()
	require("fzf-lua").grep({ cwd = M.dir })
end

-- open (or create) today's daily note
function M.daily()
	ensure_dirs()
	local date = os.date("%Y-%m-%d")
	local path = daily_dir .. "/" .. date .. ".md"
	local is_new = vim.fn.filereadable(path) == 0
	vim.cmd("edit " .. vim.fn.fnameescape(path))
	if is_new then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. date, "" })
		vim.api.nvim_win_set_cursor(0, { 2, 0 })
	end
end

-- prompt for a title, create notes/<slug>.md
function M.new()
	ensure_dirs()
	vim.ui.input({ prompt = "Note title: " }, function(title)
		if not title or title == "" then
			return
		end
		local slug = title:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-")
		local path = M.dir .. "/" .. slug .. ".md"
		local is_new = vim.fn.filereadable(path) == 0
		vim.cmd("edit " .. vim.fn.fnameescape(path))
		if is_new then
			vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. title, "" })
			vim.api.nvim_win_set_cursor(0, { 2, 0 })
		end
	end)
end

return M
