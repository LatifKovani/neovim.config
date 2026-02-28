return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		notify = {
			enabled = false,
		},

		messages = {
			enabled = false,
		},

		lsp = {
			progress = { enabled = false },
			hover = { enabled = false },
			signature = { enabled = false },
			message = { enabled = false },
		},

		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			format = {
				cmdline = { icon = " " },
				search_down = { icon = " " },
				search_up = { icon = " " },
				filter = { icon = " " },
				lua = { icon = " " },
				help = { icon = "󰋖 " },
			},
		},

		popupmenu = {
			enabled = true,
			backend = "nui",
		},

		redirect = { enabled = false },
		routes = {},
		views = {
			cmdline_popup = {
				position = {
					row = "10%",
					col = "50%",
				},
				size = {
					width = 40,
					height = "auto",
				},
				border = {
					style = "rounded",
					padding = { 0, 1 },
				},
			},
			cmdline = {
				enabled = false,
			},
		},
	},
}
