-- nvim-treesitter `main` branch: plain imperative setup (no lazy.nvim spec table,
-- which vim-plug would simply discard) -- see :h nvim-treesitter

local langs = {
	"bash", "c", "css", "cpp", "diff", "go", "html", "java", "javascript",
	"json", "lua", "luadoc", "markdown", "markdown_inline", "python",
	"query", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
}

local ts = require("nvim-treesitter")
ts.setup()

-- install anything missing, once, in the background.
-- the `main` branch compiles with the tree-sitter CLI; without it every install
-- fails noisily, so check first. Neovim still ships parsers for c/lua/markdown/
-- query/vim/vimdoc, which is why highlighting mostly works anyway.
if vim.fn.executable("tree-sitter") == 1 then
	local installed = ts.get_installed("parsers")
	local missing = vim.tbl_filter(function(l)
		return not vim.tbl_contains(installed, l)
	end, langs)
	if #missing > 0 then
		ts.install(missing)
	end
else
	vim.api.nvim_create_user_command("TSInstallHelp", function()
		vim.notify("nvim-treesitter (main) needs the tree-sitter CLI: sudo pacman -S tree-sitter-cli", vim.log.levels.WARN)
	end, { desc = "why parsers aren't installing" })
end

-- highlighting + treesitter indent for those filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = langs,
	callback = function()
		pcall(vim.treesitter.start)
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
