return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "",
		},
		preset = "classic",
		win = {
			border = vim.g.border_enabled and "rounded" or "none",
			no_overlap = false,
		},
		delay = function()
			return 0
		end,
	},
	config = function(_, opts)
		require("which-key").setup(opts)
		require("which-key").add({
			{
				{ "<leader>s", group = "Sessions", icon = "󰔚 " },
				{ "<leader>e", group = "FileExplorer", icon = "󰮗 " },
				{ "<leader>f", group = "Find", icon = " " },
				{ "<leader>l", group = "Neovim", icon = " " },
				{ "<leader>r", group = "Replace Word", icon = "󰛔 " },
				{ "<leader>t", group = "Terminal", icon = " " },
				{ "<leader>x", group = "Diagnostics", icon = " " },
				{ "<leader>b", group = "Buffers", icon = " " },
				{ "<leader>g", group = "Git", icon = " " },
				{ "<leader>G", group = "Git", icon = " " },
				{ "<leader>m", group = "Format ", icon = "󰉣 " },
			},
		})
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#040405" })
		vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "#040405", fg = "#565f89" })
		vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#040405" })
	end,
}
