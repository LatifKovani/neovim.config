return {
	"j-morano/buffer_manager.nvim",
	enabled = true,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local opts = { noremap = true, silent = true }
		local keymap = vim.keymap

		vim.api.nvim_set_hl(0, "BufferManagerNormal", { bg = "#040405", fg = "#ebdbb2" })
		vim.api.nvim_set_hl(0, "BufferManagerBorder", { bg = "#040405", fg = "#565f89" })

		require("buffer_manager").setup({
			select_menu_item_commands = {},
			focus_alternate_buffer = false,
			short_file_names = true,
			short_term_names = true,
			loop_nav = true,
			line_keys = "",
			width = 0.7,
			height = 0.5,
			win_extra_options = {
				winhighlight = "Normal:BufferManagerNormal,NormalFloat:BufferManagerNormal,FloatBorder:BufferManagerBorder,EndOfBuffer:BufferManagerNormal",
				number = false,
				relativenumber = false,
			},
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		})

		local original_normalfloat = vim.api.nvim_get_hl(0, { name = "NormalFloat" })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "buffer_manager",
			callback = function()
				vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#040405", fg = "#ebdbb2" })
			end,
		})

		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "*",
			callback = function()
				if vim.bo.filetype == "buffer_manager" then
					vim.api.nvim_set_hl(0, "NormalFloat", original_normalfloat)
				end
			end,
		})

		keymap.set("n", "<leader>bm", function()
			require("buffer_manager.ui").toggle_quick_menu()
		end, vim.tbl_extend("force", opts, { desc = "Buffer Manager (GUI)" }))
	end,
}
