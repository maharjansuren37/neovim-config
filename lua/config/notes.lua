-- lightweight note-taking: plain markdown files in the notes vault, no plugin needed
-- reuses fzf-lua for find/grep and render-markdown + the existing
-- FileType markdown autocmd (spell+wrap) for viewing

local M = {}

M.dir = vim.fn.expand("~/para/02-areas/hnoteverse")
local daily_dir = M.dir .. "/daily"

local function ensure_dirs()
	vim.fn.mkdir(daily_dir, "p")
end

-- open path, seeding it with `lines` if it doesn't exist yet
local function open(path, lines)
	local is_new = vim.fn.filereadable(path) == 0
	vim.cmd("edit " .. vim.fn.fnameescape(path))
	if is_new and lines then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { #lines, 0 })
	end
end

function M.find()
	ensure_dirs()
	require("fzf-lua").files({ cwd = M.dir, prompt = "Notes> " })
end

function M.grep()
	ensure_dirs()
	require("fzf-lua").live_grep({ cwd = M.dir, prompt = "NoteGrep> " })
end

-- open (or create) a daily note, `offset` days from today
function M.daily(offset)
	ensure_dirs()
	local t = os.time() + (offset or 0) * 86400
	local date = os.date("%Y-%m-%d", t)
	open(daily_dir .. "/" .. date .. ".md", {
		"# " .. date .. " (" .. os.date("%A", t) .. ")",
		"",
		"## Log",
		"",
		"",
		"## Tasks",
		"",
		"- [ ] ",
	})
end

function M.yesterday()
	M.daily(-1)
end

-- vault index note: the one place to start from
function M.index()
	ensure_dirs()
	open(M.dir .. "/index.md", { "# Index", "" })
end

-- prompt for a title, create <vault>/<slug>.md
function M.new()
	ensure_dirs()
	vim.ui.input({ prompt = "Note title: " }, function(title)
		if not title or title == "" then
			return
		end
		local slug = title:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-")
		open(M.dir .. "/" .. slug .. ".md", {
			"# " .. title,
			"",
			"*" .. os.date("%Y-%m-%d") .. "*",
			"",
			"",
		})
	end)
end

-- pick a note and insert a [[wikilink]] to it at the cursor
function M.link()
	ensure_dirs()
	require("fzf-lua").files({
		cwd = M.dir,
		prompt = "Link> ",
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end
				local path = require("fzf-lua").path.entry_to_file(selected[1]).path
				local name = vim.fn.fnamemodify(path, ":t:r")
				vim.api.nvim_put({ "[[" .. name .. "]]" }, "c", true, true)
			end,
		},
	})
end

-- every unchecked task across the vault
function M.todos()
	ensure_dirs()
	require("fzf-lua").grep({
		cwd = M.dir,
		search = "^\\s*[-*] \\[ \\]",
		no_esc = true,
		prompt = "TODO> ",
	})
end

-- notes that [[link]] to the current one
function M.backlinks()
	local name = vim.fn.expand("%:t:r")
	if name == "" then
		return
	end
	require("fzf-lua").grep({
		cwd = M.dir,
		search = "\\[\\[" .. vim.fn.escape(name, "\\[]") .. "([|#][^]]*)?\\]\\]",
		no_esc = true,
		prompt = "Backlinks> ",
	})
end

-- toggle `- [ ]` <-> `- [x]` on the current line, adding a checkbox if missing
function M.toggle_checkbox()
	local line = vim.api.nvim_get_current_line()
	local new
	if line:match("^%s*[-*] %[ %]") then
		new = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("^%s*[-*] %[[xX]%]") then
		new = line:gsub("%[[xX]%]", "[ ]", 1)
	elseif line:match("^%s*[-*] ") then
		new = line:gsub("^(%s*[-*] )", "%1[ ] ", 1)
	else
		new = line:gsub("^(%s*)(.*)$", "%1- [ ] %2", 1)
	end
	vim.api.nvim_set_current_line(new)
end

-- follow the [[wikilink]] under the cursor, creating the note if it's new
function M.follow_link()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	for s, target in line:gmatch("()%[%[([^%]]+)%]%]") do
		local e = s + #target + 3
		if col >= s and col <= e then
			local name = target:match("^([^|#]+)") or target
			name = vim.trim(name)
			local path = name:match("%.md$") and (M.dir .. "/" .. name) or (M.dir .. "/" .. name .. ".md")
			open(path, { "# " .. name, "" })
			return true
		end
	end
	return false
end

return M
