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
	wrap = true, --toggle bound to leader W
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
	relativenumber = true, --toggle bound to leader nn
	numberwidth = 4,

	smarttab = true, --indentation stuff
	cindent = true,
	autoindent = false,
	tabstop = 4, --visual width of tab

	foldmethod = "expr",
	foldlevel = 99, --disable folding, lower #s enable
	foldexpr = "nvim_treesitter#foldexpr()",
	
	termguicolors = true,

	ignorecase = true, --ignore case while searching
	smartcase = true, --but do not ignore if caps are used

	conceallevel = 2, --markdown conceal
	concealcursor = "nc",

	splitkeep = 'screen', --stablizie window open/close
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
})
