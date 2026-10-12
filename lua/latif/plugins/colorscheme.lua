-- Colourschemes. Which one is active is decided by the system theme (see latif/theme.lua):
-- every scheme below is lazy-loaded on demand; the first spec just kicks the theme module off.
return {
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		lazy = false,
		config = function()
			require("latif.theme").setup()

			vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
				pattern = "*",
				callback = function()
					vim.fn.matchadd("CurlyBrace", "[{}]")
				end,
			})
		end,
	},
	{ "gbprod/nord.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "Mofiqul/dracula.nvim", lazy = true },
}
