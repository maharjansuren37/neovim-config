-- linters_by_ft used by the BufWritePost autocmd in config.autocmd;
-- try_lint() no-ops per-filetype when the tool below isn't installed
require("lint").linters_by_ft = {
	python = { "ruff" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
}
