-- file operations on the buffer you're already in: create, rename, move,
-- duplicate, delete, copy path. All of it is `vim.ui.input` + `vim.ui.select`,
-- so it works the same from a normal buffer or from nvim-tree.
--
-- Renames go through vim.lsp.util.rename when a server is attached, so imports
-- that reference the old path get updated instead of silently breaking.

local M = {}

local function err(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

local function cur()
	local p = vim.api.nvim_buf_get_name(0)
	return p ~= "" and p or nil
end

-- directory to hang new files off: the current file's, else cwd
local function here()
	local p = cur()
	return p and vim.fn.fnamemodify(p, ":p:h") or vim.fn.getcwd()
end

local function shorten(path)
	return vim.fn.fnamemodify(path, ":~:.")
end

-- ask, defaulting to `default`; `completion` is a :command completion type
local function ask(prompt, default, completion, fn)
	vim.ui.input({ prompt = prompt, default = default, completion = completion }, function(answer)
		if not answer or vim.trim(answer) == "" then
			return
		end
		fn(vim.fn.expand(vim.trim(answer)))
	end)
end

local function confirm(prompt, fn)
	vim.ui.select({ "no", "yes" }, { prompt = prompt }, function(choice)
		if choice == "yes" then
			fn()
		end
	end)
end

-- every prompt shows paths relative to the cwd (shorten/`:~:.`), so a relative
-- answer resolves against the cwd too - otherwise editing the prefilled default
-- of a file in a subdirectory nests the path a second time
local function resolve(path)
	if path:sub(1, 1) == "/" then
		return path
	end
	return vim.fn.getcwd() .. "/" .. path
end

local function mkparent(path)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
end

-- ── create ───────────────────────────────────────────────────────────────────

-- new file next to the current one; nested paths create their own dirs
function M.new()
	ask("New file: ", shorten(here()) .. "/", "file", function(input)
		local path = resolve(input)
		if vim.fn.filereadable(path) == 1 then
			return vim.cmd.edit(vim.fn.fnameescape(path))
		end
		mkparent(path)
		vim.cmd.edit(vim.fn.fnameescape(path))
		vim.notify("new file " .. shorten(path))
	end)
end

function M.new_dir()
	ask("New directory: ", shorten(here()) .. "/", "dir", function(input)
		local path = resolve(input)
		if vim.fn.mkdir(path, "p") == 0 then
			return err("could not create " .. shorten(path))
		end
		vim.notify("created " .. shorten(path))
	end)
end

-- ── move / rename ────────────────────────────────────────────────────────────

-- the actual move: LSP-aware when a server can follow it, plain rename otherwise
local function move(src, dest)
	if vim.fn.filereadable(dest) == 1 or vim.fn.isdirectory(dest) == 1 then
		return err(shorten(dest) .. " already exists")
	end
	mkparent(dest)

	if vim.bo.modified then
		vim.cmd("silent! write")
	end

	local ok = pcall(vim.lsp.util.rename, src, dest)
	if not ok then
		if vim.fn.rename(src, dest) ~= 0 then
			return err("rename failed: " .. shorten(src))
		end
		local buf = vim.fn.bufnr(src)
		vim.cmd.edit(vim.fn.fnameescape(dest))
		if buf ~= -1 and buf ~= vim.api.nvim_get_current_buf() then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
	vim.notify(shorten(src) .. "  ->  " .. shorten(dest))
end

-- rename in place: only the name changes, the directory stays put
function M.rename()
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	ask("Rename to: ", vim.fn.fnamemodify(src, ":t"), nil, function(name)
		move(src, vim.fn.fnamemodify(src, ":p:h") .. "/" .. name)
	end)
end

-- move: the whole path is editable, so this also renames
function M.move()
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	ask("Move to: ", shorten(src), "file", function(input)
		move(src, resolve(input))
	end)
end

-- ── copy / delete ────────────────────────────────────────────────────────────

-- duplicate, defaulting to name-copy.ext so <CR> is always a safe answer
function M.duplicate()
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	local ext = vim.fn.fnamemodify(src, ":e")
	local suffix = ext ~= "" and ("." .. ext) or ""
	local default = vim.fn.fnamemodify(src, ":r") .. "-copy" .. suffix
	local i = 1
	while vim.fn.filereadable(default) == 1 do
		default = vim.fn.fnamemodify(src, ":r") .. "-copy" .. i .. suffix
		i = i + 1
	end

	ask("Copy to: ", shorten(default), "file", function(input)
		local dest = resolve(input)
		if vim.fn.filereadable(dest) == 1 then
			return err(shorten(dest) .. " already exists")
		end
		mkparent(dest)
		if vim.bo.modified then
			vim.cmd("silent! write")
		end
		if not vim.uv.fs_copyfile(src, dest) then
			return err("copy failed")
		end
		vim.cmd.edit(vim.fn.fnameescape(dest))
		vim.notify("copied to " .. shorten(dest))
	end)
end

-- delete the file on disk and drop its buffer; always asks first
function M.delete()
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	if vim.fn.filereadable(src) == 0 then
		return err("not saved to disk yet")
	end
	confirm("Delete " .. shorten(src) .. "?", function()
		if vim.fn.delete(src) ~= 0 then
			return err("delete failed")
		end
		vim.api.nvim_buf_delete(0, { force = true })
		vim.notify("deleted " .. shorten(src))
	end)
end

-- ── paths & misc ─────────────────────────────────────────────────────────────

-- copy a path to the system clipboard; `how` picks which form
function M.copy_path(how)
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	local path = ({
		absolute = vim.fn.fnamemodify(src, ":p"),
		relative = vim.fn.fnamemodify(src, ":."),
		name = vim.fn.fnamemodify(src, ":t"),
		dir = vim.fn.fnamemodify(src, ":p:h"),
	})[how or "relative"]
	vim.fn.setreg("+", path)
	vim.notify("copied " .. path)
end

-- chmod +x, for the scripts this config is mostly used to write
function M.chmod_x()
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	vim.fn.system({ "chmod", "+x", src })
	vim.notify("chmod +x " .. vim.fn.fnamemodify(src, ":t"))
end

-- reveal the current file in nvim-tree, rather than hunting for it in the tree
function M.reveal()
	local src = cur()
	if not src then
		return vim.cmd("NvimTreeToggle")
	end
	vim.cmd("NvimTreeFindFile")
end

-- hand the file to the desktop (image viewer, pdf reader, browser)
function M.open_external()
	local src = cur()
	if not src then
		return err("no file in this buffer")
	end
	vim.ui.open(src)
end

return M
