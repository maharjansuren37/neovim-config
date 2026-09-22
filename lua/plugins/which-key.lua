-- only groups and labels that the keymaps themselves can't carry;
-- every individual mapping now sets its own `desc`, so which-key picks those up
require("which-key").setup({
	preset = "helix",
	win = { border = "rounded" },
})

require("which-key").add({
	{ "<leader>f", desc = "find files" },
	{ "<leader>F", group = "find (more)" },
	{ "<leader>h", group = "git hunk" },
	{ "<leader>l", group = "lsp / format" },
	{ "<leader>n", group = "notes" },
	{ "<leader>o", group = "file ops" },
	{ "<leader>b", group = "buffers" },
	{ "<leader><leader>", desc = "switch buffer" },
	{ "g", group = "goto" },
	{ "]", group = "next" },
	{ "[", group = "prev" },
})
