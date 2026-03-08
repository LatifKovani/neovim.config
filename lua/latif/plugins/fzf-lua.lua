return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			"default",
			winopts = {
				height = 0.85,
				width = 0.85,
				row = 0.35,
				col = 0.50,
				border = "rounded",
				preview = {
					border = "rounded",
					wrap = "nowrap",
					hidden = "nohidden",
					vertical = "down:45%",
					horizontal = "right:50%",
					layout = "flex",
					flip_columns = 120,
				},
			},
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
				fzf = {
					["ctrl-j"] = "down",
					["ctrl-k"] = "up",
					["ctrl-q"] = "select-all+accept",
				},
			},
			fzf_opts = {
				["--layout"] = "reverse",
				["--info"] = "inline",
			},
			files = {
				formatter = "path.filename_first",
				git_icons = true,
				file_icons = true,
				color_icons = true,
			},
			grep = {
				formatter = "path.filename_first",
				git_icons = true,
				file_icons = true,
				color_icons = true,
			},
			lsp = {
				jump_to_single_result = true,
				ignore_current_line = true,
			},
			diagnostics = {
				file_icons = true,
				color_icons = true,
			},
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>ff", fzf.files, { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fs", fzf.live_grep, { desc = "Find string in cwd" })
		keymap.set("n", "<leader>ft", fzf.grep, { desc = "Find todos (fzf grep)" })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("FzfLspKeymaps", { clear = true }),
			callback = function(event)
				local opts = { noremap = true, silent = true, buffer = event.buf }

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", fzf.lsp_references, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", fzf.lsp_definitions, opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", fzf.lsp_implementations, opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", fzf.lsp_typedefs, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", function()
					fzf.diagnostics_document()
				end, opts)
			end,
		})
	end,
}
