return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"html",
				"css",
				"scss",
				"javascript",
				"typescript",
				"tsx",
				"python",
				"markdown",
				"markdown_inline",
				"json",
				"yaml",
				"toml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<leader>ss",
					node_incremental = "<leader>si",
					scope_incremental = "<leader>sc",
					node_decremental = "<leader>sd",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
						["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
					},
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<c-v>",
					},
					include_surrounding_whitespace = true,
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
