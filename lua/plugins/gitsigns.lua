require("gitsigns").setup({
	signs = {
		add          = { text = '│' },
		change       = { text = '│' },
		delete       = { text = '_' },
		topdelete    = { text = '‾' },
		changedelete = { text = '~' },
		untracked    = { text = '┆' },
	},
	on_attach = function(bufnr)
		local gs = require("gitsigns")

		local function map(mode, lhs, rhs, desc, opts)
			opts = opts or {}
			opts.buffer = bufnr
			opts.desc = desc
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- navigate hunks
		map("n", "]c", function()
			if vim.wo.diff then return "]c" end
			vim.schedule(gs.next_hunk)
			return "<Ignore>"
		end, "next hunk", { expr = true })

		map("n", "[c", function()
			if vim.wo.diff then return "[c" end
			vim.schedule(gs.prev_hunk)
			return "<Ignore>"
		end, "prev hunk", { expr = true })

		-- hunk actions
		map("n", "<leader>hs", gs.stage_hunk, "stage hunk")
		map("n", "<leader>hr", gs.reset_hunk, "reset hunk")
		map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "stage hunk")
		map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "reset hunk")
		map("n", "<leader>hS", gs.stage_buffer, "stage buffer")
		map("n", "<leader>hR", gs.reset_buffer, "reset buffer")
		map("n", "<leader>hu", gs.undo_stage_hunk, "undo stage hunk")
		map("n", "<leader>hp", gs.preview_hunk, "preview hunk")
		map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "blame line")
		map("n", "<leader>hB", gs.toggle_current_line_blame, "toggle line blame")
		map("n", "<leader>hd", gs.diffthis, "diff this")

		-- hunk text object
		map({ "o", "x" }, "ih", gs.select_hunk, "select hunk")
	end,
})
