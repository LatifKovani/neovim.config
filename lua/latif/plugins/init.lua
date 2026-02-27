return {
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use
	{
		"aserowy/tmux.nvim",
		config = function()
			require("tmux").setup({
				navigation = {
					enable_default_keybindings = true,
				},
				resize = {
					enable_default_keybindings = true,
				},
			})
		end,
	},
}
