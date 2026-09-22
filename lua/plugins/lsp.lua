-- native LSP setup (Neovim's built-in vim.lsp.enable/vim.lsp.config), no mason:
-- install a server yourself (e.g. `sudo pacman -S lua-language-server`) and it
-- is picked up automatically here once its command is on $PATH.

local capabilities = require("blink.cmp").get_lsp_capabilities()

-- lspconfig server name -> executable to probe for; only enabled if found
local servers = {
	lua_ls = "lua-language-server",
	pyright = "pyright-langserver",
	basedpyright = "basedpyright-langserver",
	ruff = "ruff",
	ts_ls = "typescript-language-server",
	gopls = "gopls",
	rust_analyzer = "rust-analyzer",
	clangd = "clangd",
	bashls = "bash-language-server",
	marksman = "marksman", -- markdown/wikilink support, useful for the notes vault
}

for name, cmd in pairs(servers) do
	if vim.fn.executable(cmd) == 1 then
		vim.lsp.config(name, { capabilities = capabilities })
		vim.lsp.enable(name)
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "gd", function() require("fzf-lua").lsp_definitions() end, "goto definition")
		map("n", "gD", vim.lsp.buf.declaration, "goto declaration")
		map("n", "gr", function() require("fzf-lua").lsp_references() end, "references")
		map("n", "gi", function() require("fzf-lua").lsp_implementations() end, "goto implementation")
		map("n", "K", vim.lsp.buf.hover, "hover")
		map("n", "<leader>rn", vim.lsp.buf.rename, "rename")
		map("n", "<leader>ca", function() require("fzf-lua").lsp_code_actions() end, "code action")
		map("n", "<leader>ss", function() require("fzf-lua").lsp_document_symbols() end, "document symbols")
		map("n", "<leader>sw", function() require("fzf-lua").lsp_workspace_symbols() end, "workspace symbols")

		-- these groups only exist where a server is attached, so they are
		-- registered per-buffer instead of showing up empty everywhere
		local ok, wk = pcall(require, "which-key")
		if ok then
			wk.add({
				buffer = bufnr,
				{ "<leader>s", group = "symbols" },
				{ "<leader>c", group = "code" },
				{ "<leader>r", group = "refactor" },
			})
		end
	end,
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "line diagnostics" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "next diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "prev diagnostic" })
