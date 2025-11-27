return {
	"gbprod/substitute.nvim",
	event = "VeryLazy",
	config = function()
		pcall(require, "substitute")

		local function safe_escape(str, chars)
			return vim.fn.escape(str, chars)
		end

		local function get_user_input(prompt)
			local input = vim.fn.input(prompt)
			return input ~= "" and input or nil
		end

		local function replace_word_under_cursor_no_confirm()
			local word = vim.fn.expand("<cword>")
			if word == "" then
				vim.notify("No word under cursor.", vim.log.levels.WARN)
				return
			end

			local repl = get_user_input('Replace word "' .. word .. '" with: ')
			if not repl then
				return
			end

			vim.cmd(string.format("%%s/\\V\\<%s\\>/%s/g", safe_escape(word, "\\/"), safe_escape(repl, "/\\&")))
		end

		local function replace_last_search_no_confirm()
			local search = vim.fn.getreg("/")
			if search == "" then
				vim.notify("No last search pattern. Use /pattern first.", vim.log.levels.WARN)
				return
			end

			local repl = get_user_input('Replace "' .. search .. '" with: ')
			if not repl then
				return
			end

			vim.cmd(string.format("%%s/%s/%s/g", safe_escape(search, "/\\"), safe_escape(repl, "/\\&")))
		end

		local function clear_search_highlight()
			vim.cmd("nohlsearch")
			vim.fn.setreg("/", "")
			vim.notify("Search highlights cleared", vim.log.levels.INFO)
		end

		local keymaps = {
			{
				"n",
				"<leader>rw",
				replace_word_under_cursor_no_confirm,
				"Replace word under cursor (no confirm, buffer-wide)",
			},
			{ "n", "<leader>ra", replace_last_search_no_confirm, "Replace all matches of last search (no confirm)" },
			{ "n", "<leader>nh", clear_search_highlight, "Clear search highlights" },
		}

		for _, map in ipairs(keymaps) do
			vim.keymap.set(map[1], map[2], map[3], {
				noremap = true,
				silent = true,
				desc = map[4],
			})
		end
	end,
}
