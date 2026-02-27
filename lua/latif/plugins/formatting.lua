return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescriptreact = { "prettierd" },
				html = { "prettierd" },
				css = { "prettierd" },
				scss = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				python = { "isort", "black" },
				lua = { "stylua" },
			},
			format_on_save = {
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range" })
	end,
}
