vim.cmd("let g:netrw_liststyle = 3")
local opt = vim.opt

opt.relativenumber = true
opt.number = true
vim.opt.linespace = 7
vim.opt.clipboard = "unnamedplus"
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = true
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cmdheight = 0

vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		vim.fn.setreg("+", vim.fn.system("wl-paste --no-newline"))
		vim.fn.setreg("*", vim.fn.system("wl-paste --no-newline"))
	end,
})

-- Line number color on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ea6962", bold = true })
	end,
})

opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
