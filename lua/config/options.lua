-- Basic settings
--vim.opt.number = true -- enable line numbers
--vim.opt.cursorline = true -- higlight the current line
--vim.opt.relativenumber = true -- enable relative line number
--vim.opt.shiftwidth = 4 -- number of spaces for each indentatic
--vim.opt.tabstop = 4 -- number of spaces a tab represents
--vim.opt.expandtab = true -- convert tabs to spaces
--vim.opt.smartindent = true -- automatically indent new lines
--vim.o.wrap = false -- disable line wrapping
--vim.o.termguicolors = true -- enable 24-bit RGB colors

local options = {
	laststatus = 3,
	ruler = false, --disable extra numbering
	showmode = false, --redundant with cmdline/statusline info
	showcmd = false,
	wrap = true, --toggle bound to <leader>W
	mouse = "a", --enable mouse
	clipboard = "unnamedplus", --system clipboard integration
	history = 100, --command line history
	swapfile = false, --swap just gets in the way, usually
	backup = false,
	undofile = true, --undos are saved to file
	cursorline = true, --highlight line
	ttyfast = true, --faster scrolling
	smoothscroll = true,
	title = true, --automatic window titlebar
	
	number = true, --numbering lines
	relativenumber = true, --toggle bound to <leader>N
	numberwidth = 4,

	smarttab = true, --indentation stuff
	expandtab = true, --tabs -> spaces (treesitter/LSP indent expects this)
	tabstop = 4, --visual width of tab
	shiftwidth = 4, --width of one indent step
	softtabstop = 4, --<Tab>/<BS> move by one indent step
	smartindent = true,

	foldmethod = "expr",
	foldlevel = 99, --disable folding, lower #s enable
	foldexpr = "v:lua.vim.treesitter.foldexpr()", --nvim-treesitter main dropped the vimscript fn
	foldtext = "",
	
	termguicolors = true,

	ignorecase = true, --ignore case while searching
	smartcase = true, --but do not ignore if caps are used

	conceallevel = 2, --markdown conceal
	concealcursor = "nc",

	splitkeep = 'screen', --stablizie window open/close

	signcolumn = "yes", --always on, so gitsigns/diagnostics don't shift text
	scrolloff = 8, --keep context around the cursor
	sidescrolloff = 8,
	updatetime = 250, --faster CursorHold (diagnostics, gitsigns blame)
	timeoutlen = 400, --how long which-key waits
	splitbelow = true, --new splits go where you expect
	splitright = true,
	confirm = true, --prompt instead of failing on unsaved changes
	undolevels = 10000,
	completeopt = "menuone,noselect",
	inccommand = "split", --live preview for :s
	linebreak = true, --wrap at word boundaries, not mid-word
	breakindent = true, --keep wrapped lines indented
	pumheight = 12, --cap completion popup height
	winborder = "rounded", --rounded borders for hover/diagnostic floats
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- show open buffers in the tab bar
vim.opt.showtabline = 2
function _G.tabline_buffers()
		local line = {}
		for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
				local name = vim.fn.fnamemodify(buf.name, ':t')
				if name == '' then name = '[No Name]' end
				if buf.bufnr == vim.fn.bufnr('%') then
						table.insert(line, '%#TabLineSel#' .. ' ' .. name .. ' %#TabLineFill#')
				else
						table.insert(line, '%#TabLine#' .. ' ' .. name .. ' %#TabLineFill#')
				end
		end
		return table.concat(line)
end
vim.opt.tabline = '%!v:lua.tabline_buffers()'

vim.diagnostic.config({
	signs = false,
	underline = true,
	severity_sort = true,
	virtual_text = { spacing = 2, prefix = "\u{25cf}" }, -- inline message, so errors are visible without a keypress
	float = { border = "rounded", source = "if_many" },
})

-- statusline: laststatus=3 means one global bar, so it may as well say something
function _G.statusline()
	local parts = { " %<%f%m%r" }

	local function count(sev)
		return #vim.diagnostic.get(0, { severity = sev })
	end
	local e, w = count(vim.diagnostic.severity.ERROR), count(vim.diagnostic.severity.WARN)
	if e > 0 then parts[#parts + 1] = "  E" .. e end
	if w > 0 then parts[#parts + 1] = "  W" .. w end

	local git = vim.b.gitsigns_head
	if git then parts[#parts + 1] = "  \u{e0a0} " .. git end

	parts[#parts + 1] = "%="
	parts[#parts + 1] = (vim.bo.filetype ~= "" and vim.bo.filetype .. "  " or "")
	parts[#parts + 1] = "%l:%c  %P "
	return table.concat(parts)
end
vim.opt.statusline = "%!v:lua.statusline()"
