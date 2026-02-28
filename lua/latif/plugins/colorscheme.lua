return {
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		lazy = false,
		config = function()
			vim.g.gruvbox_material_transparent_background = 1
			vim.g.gruvbox_material_foreground = "mix"
			vim.g.gruvbox_material_background = "hard"
			vim.g.gruvbox_material_ui_contrast = "high"
			vim.g.gruvbox_material_float_style = "bright"
			vim.g.gruvbox_material_statusline_style = "mix"
			vim.g.gruvbox_material_cursor = "auto"

			vim.cmd.colorscheme("gruvbox-material")

			vim.api.nvim_set_hl(0, "CurlyBrace", { fg = "#c14a4a" })
			vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
				pattern = "*",
				callback = function()
					vim.fn.matchadd("CurlyBrace", "[{}]")
				end,
			})
		end,
	},
}
