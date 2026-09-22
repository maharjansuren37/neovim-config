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
	-- format on save, but only when a formatter for the filetype is actually
	-- installed, so a missing prettierd never blocks a write. <leader>lF
	-- toggles it off when you're editing someone else's unformatted code.
	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return nil
		end
		-- notes autosave on every InsertLeave; letting prettier rewrap them
		-- on each of those writes moves text out from under the cursor
		local vault = vim.fn.expand("~/para/02-areas/hnoteverse")
		if vim.startswith(vim.api.nvim_buf_get_name(bufnr), vault) then
			return nil
		end
		-- list_formatters_to_run returns FormatterInfo entries carrying `available`
		local runnable, uses_lsp = require("conform").list_formatters_to_run(bufnr)
		local have = uses_lsp or #vim.tbl_filter(function(f) return f.available end, runnable) > 0
		if not have then
			return nil
		end
		return { timeout_ms = 1000, lsp_format = "fallback" }
	end,
})

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	require("conform").format({ lsp_format = "fallback", timeout_ms = 1000 })
end, { desc = "format buffer/selection" })

vim.keymap.set("n", "<leader>lF", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	vim.notify("format on save: " .. (vim.g.disable_autoformat and "off" or "on"))
end, { desc = "toggle format on save" })
