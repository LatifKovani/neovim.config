return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local todo_comments = require("todo-comments")
		local keymap = vim.keymap
		keymap.set("n", "<leader>td", function()
			vim.api.nvim_put({ "-- TODO: " }, "c", true, true)
		end, { desc = "Insert TODO comment" })
		keymap.set("n", "<leader>tf", function()
			vim.api.nvim_put({ "-- FIX: " }, "c", true, true)
		end, { desc = "Insert FIX comment" })
		keymap.set("n", "<leader>tn", function()
			vim.api.nvim_put({ "-- NOTE: " }, "c", true, true)
		end, { desc = "Insert NOTE comment" })
		keymap.set("n", "<leader>tw", function()
			vim.api.nvim_put({ "-- WARN: " }, "c", true, true)
		end, { desc = "Insert WARN comment" })
		keymap.set("n", "<leader>th", function()
			vim.api.nvim_put({ "-- HACK: " }, "c", true, true)
		end, { desc = "Insert HACK comment" })
		keymap.set("n", "<leader>tp", function()
			vim.api.nvim_put({ "-- PERF: " }, "c", true, true)
		end, { desc = "Insert PERF comment" })
		keymap.set("n", "<leader>tt", function()
			vim.api.nvim_put({ "-- TEST: " }, "c", true, true)
		end, { desc = "Insert TEST comment" })
		keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next todo comment" })
		keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous todo comment" })
		todo_comments.setup({
			keywords = {
				FIX = { icon = "󰁨 ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
				TODO = { icon = " ", color = "info" },
				HACK = { icon = "󰈸 ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = "󰓅 ", color = "hint", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = "󰍨 ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			colors = {
				error = { "DiagnosticError", "#ff3b30" },
				warning = { "DiagnosticWarn", "#ff9f0a" },
				info = { "DiagnosticInfo", "#0a84ff" },
				hint = { "DiagnosticHint", "#30d158" },
				test = { "DiagnosticHint", "#bf5af2" },
			},
		})
	end,
}
