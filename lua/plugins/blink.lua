require("blink.cmp").setup({
	keymap = { preset = "default" }, -- <C-space> trigger, <CR> accept, <C-n>/<C-p> select
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = { auto_show = true },
	},
	sources = {
		default = { "lsp", "path", "buffer" },
	},
	signature = { enabled = true },
})
