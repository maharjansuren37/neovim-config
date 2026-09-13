require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		go = { "gofmt" },
		rust = { "rustfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	},
	-- no format_on_save: none of the above formatters are installed on this
	-- system yet, so it would just error on every write. Use <leader>lf once
	-- you've installed the relevant formatter, then add format_on_save here.
})

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	require("conform").format({ lsp_fallback = true, timeout_ms = 1000 })
end, { desc = "format buffer" })
