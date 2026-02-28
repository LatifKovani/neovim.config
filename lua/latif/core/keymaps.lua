vim.g.mapleader = " "
local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<C-s>", ":w<CR>", { noremap = true, silent = true, desc = "Save file" })
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { noremap = true, silent = true, desc = "Save file (insert mode)" })
keymap.set("n", "<C-q>", ":q<CR>", { noremap = true, silent = true, desc = "Quit" })
keymap.set("n", "<C-q>i", ":q!<CR>", { noremap = true, silent = true, desc = "Quit without saving" })
keymap.set("n", "x", '"_x', { desc = "Delete single character without copying" })
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })
keymap.set("n", "E", "$", { noremap = true, desc = "Jump to end of line" })

-- ── Surround ──────────────────────────────────────────────────────────────────
--   ysiw"         -> wrap word with quotes
--   yss<div>      -> wrap line with div
--   ds"           -> delete surrounding quotes
--   cs"'          -> change quotes to single quotes

keymap.set("n", "ys", "<Plug>(nvim-surround-normal)", { desc = "Surround: add (motion)" })
keymap.set("n", "yss", "<Plug>(nvim-surround-normal-cur)", { desc = "Surround: add (line)" })
keymap.set("n", "yS", "<Plug>(nvim-surround-normal-line)", { desc = "Surround: add (line mode)" })
keymap.set("n", "ySS", "<Plug>(nvim-surround-normal-cur-line)", { desc = "Surround: add (current line)" })
keymap.set("v", "S", "<Plug>(nvim-surround-visual)", { desc = "Surround: add (visual)" })
keymap.set("v", "gS", "<Plug>(nvim-surround-visual-line)", { desc = "Surround: add (visual line)" })
keymap.set("n", "ds", "<Plug>(nvim-surround-delete)", { desc = "Surround: delete" })
keymap.set("n", "cs", "<Plug>(nvim-surround-change)", { desc = "Surround: change" })
keymap.set("n", "cS", "<Plug>(nvim-surround-change-line)", { desc = "Surround: change (line)" })

-- ── Buffers ───────────────────────────────────────────────────────────────────
-- Note: <leader>bb and <Tab> for buffer switching are handled in fzf-lua.lua
keymap.set("n", "<leader>bn", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
keymap.set("n", "<leader>bp", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
keymap.set("n", "<leader>ba", "<C-^>", { noremap = true, silent = true, desc = "Alternate buffer" })
keymap.set("n", "<leader>bd", ":bdelete<CR>", { noremap = true, silent = true, desc = "Delete buffer" })
keymap.set("n", "<leader>bl", ":buffers<CR>:buffer<Space>", { noremap = true, desc = "List and select buffer" })
keymap.set("n", "<S-Tab>", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })

-- ── Splits ────────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- ── Tabs ──────────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

-- ── LSP (buffer-local, only active when LSP attaches) ─────────────────────────
-- Note: gR, gd, gi, gt, <leader>D are handled in fzf-lua.lua via its own LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
	callback = function(event)
		local opts = { noremap = true, silent = true, buffer = event.buf }

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>ln", vim.lsp.buf.rename, opts)

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1 })
		end, opts)

		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts)

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>ls", ":LspRestart<CR>", opts)

		keymap.set("n", "<leader>ll", function()
			require("lint").try_lint()
		end, { desc = "Trigger linting for current file" })

		vim.keymap.set("n", "<Leader>gf", vim.lsp.buf.format, {})
	end,
})
