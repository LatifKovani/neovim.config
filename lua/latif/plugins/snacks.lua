return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		notifier = {
			enabled = true,
			timeout = 3000,
			width = { min = 20, max = 0.4 },
			height = { min = 1, max = 0.6 },
			margin = { top = 1, right = 2, bottom = 0 },
			padding = true,
			sort = { "level", "added" },
			level = vim.log.levels.TRACE,
			icons = {
				error = " ",
				warn = " ",
				info = " ",
				debug = " ",
				trace = " ",
			},
			style = "compact",
			top_down = true,
			position = "top-right",
		},
		input = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
				keys = {
					{ icon = " ", key = "e", desc = "New File", action = ":ene | startinsert" },
					{ icon = "󰈞 ", key = "f", desc = "Find File", action = ":FzfLua files" },
					{ icon = "󰛔 ", key = "s", desc = "Find Word", action = ":FzfLua live_grep" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
					{ icon = "󰁯 ", key = "R", desc = "Restore Session", action = ":SessionRestore" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup" },
			},
		},
		bigfile = { enabled = false },
		quickfile = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
		scroll = { enabled = false },
		picker = { enabled = false },
	},
	config = function(_, opts)
		local snacks = require("snacks")
		snacks.setup(opts)

		local snacks_notifier = require("snacks.notifier")
		vim.notify = function(msg, level, notify_opts)
			snacks_notifier.notify(msg, vim.tbl_extend("force", notify_opts or {}, { level = level }))
		end

		local keymap = vim.keymap
		keymap.set("n", "<leader>nh", function()
			snacks.notifier.show_history()
		end, { desc = "Notification history" })
		keymap.set("n", "<leader>nd", function()
			snacks.notifier.hide()
		end, { desc = "Dismiss notifications" })
	end,
}
