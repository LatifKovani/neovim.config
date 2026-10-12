return {
	"utilyre/barbecue.nvim",
	name = "barbecue",
	version = "*",
	dependencies = {
		"SmiteshP/nvim-navic",
		"nvim-tree/nvim-web-devicons",
	},
	opts = function()
		local c = require("latif.theme").colors
		return {
			theme = {
				normal = { bg = c.bg, fg = c.yellow },
				context = { bg = c.bg, fg = c.yellow },
				dirname = { bg = c.bg, fg = c.fg_dim },
				separator = { bg = c.bg, fg = c.fg },
			},
		}
	end,
}
