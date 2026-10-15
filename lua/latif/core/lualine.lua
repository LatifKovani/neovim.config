local M = {}

local function get_recording()
	local ok, rec = pcall(vim.fn.reg_recording)
	return ok and rec ~= ""
end

local function recording_component()
	return get_recording() and "" or ""
end

local function recording_color()
	local c = require("latif.theme").colors
	return get_recording() and { fg = c.red } or { fg = c.fg_dim }
end

local _lsp_name = ""
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufEnter" }, {
	callback = function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if not clients or vim.tbl_isempty(clients) then
			_lsp_name = ""
		else
			local names = {}
			for _, c in ipairs(clients) do
				table.insert(names, c.name)
			end
			_lsp_name = table.concat(names, ", ")
		end
	end,
})
local function current_buffer_lsp()
	return _lsp_name
end

local function short_cwd()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
	end
end

local diagnostic_signs = {
	error = " ",
	warn = " ",
	info = " ",
	hint = " ",
	other = " ",
}

-- Terminal background (same as kitty / tmux). Text on coloured blocks uses it, so the
-- blocks look cut out of the transparent terminal instead of using the theme's own bg.
local TERMINAL_BG = "#040405"

-- Palette follows the active tide-theme (re-synced on every theme change)
local T = require("latif.theme")
local C = {}
local function sync_palette()
	local t = T.colors
	C.bg = TERMINAL_BG
	C.surface0 = "NONE"
	C.surface1 = t.fg
	C.surface2 = "NONE"
	C.text = t.fg_dim
	C.comment = t.fg_dim
	C.blue = t.blue
	C.cyan = t.cyan
	C.green = t.green
	C.red = t.red
	C.violet = t.magenta
	C.orange = t.accent2

	-- Mode colours: NORMAL follows the theme accent, the other modes are picked
	-- so that no two modes ever share a colour inside one theme.
	local used = { [t.accent:lower()] = true }
	local function pick(...)
		for _, col in ipairs({ ... }) do
			if col and not used[col:lower()] then
				used[col:lower()] = true
				return col
			end
		end
		return t.accent
	end
	C.mode = {
		normal = t.accent,
		insert = pick(t.green, t.cyan, t.yellow),
		visual = pick(t.magenta, t.cyan, t.blue),
		replace = pick(t.red, t.orange),
		command = pick(t.yellow, t.blue, t.magenta),
	}
end
sync_palette()

local function build_theme()
	local m = C.mode
	return {
		normal = {
			a = { fg = C.bg, bg = m.normal },
			b = { fg = C.text, bg = "NONE" },
			c = { fg = C.text, bg = "NONE" },
			x = { fg = C.text, bg = "NONE" },
			y = { fg = C.text, bg = "NONE" },
			z = { fg = C.bg, bg = m.normal },
		},
		insert = { a = { fg = C.bg, bg = m.insert }, z = { fg = C.bg, bg = m.insert } },
		visual = { a = { fg = C.bg, bg = m.visual }, z = { fg = C.bg, bg = m.visual } },
		replace = { a = { fg = C.bg, bg = m.replace }, z = { fg = C.bg, bg = m.replace } },
		command = { a = { fg = C.bg, bg = m.command }, z = { fg = C.bg, bg = m.command } },
		inactive = {
			a = { fg = C.text, bg = C.surface2 },
			b = { fg = C.text, bg = C.surface2 },
			c = { fg = C.text, bg = C.surface2 },
			z = { fg = C.text, bg = C.surface2 },
		},
	}
end

local _mode_map = {
	["COMMAND"] = "COMMND",
	["V-BLOCK"] = "V-BLCK",
	["TERMINAL"] = "TERMNL",
	["V-REPLACE"] = "V-RPLC",
	["O-PENDING"] = "0PNDNG",
}
local function fmt_mode(s)
	return _mode_map[s] or s
end

local state = { virtual_diagnostics = false, format_enabled = false, zen = false }

function M.set_virtual_diagnostics(val)
	state.virtual_diagnostics = not not val
end
function M.set_format_enabled(val)
	state.format_enabled = not not val
end
function M.set_zen(val)
	state.zen = not not val
end

local _git_cache = {}
vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		_git_cache = {}
	end,
})

local function in_git_repo()
	local cwd = vim.fn.getcwd()
	if _git_cache[cwd] ~= nil then
		return _git_cache[cwd]
	end
	local ok, out = pcall(vim.fn.systemlist, { "git", "rev-parse", "--is-inside-work-tree" })
	local result = ok and type(out) == "table" and #out > 0 and out[1] == "true"
	_git_cache[cwd] = result
	return result
end

local GITHUB_USERNAME = "LatifKovani"
local GITHUB_ICON = ""

local function github_branch_component()
	if not in_git_repo() then
		return GITHUB_USERNAME ~= "" and GITHUB_USERNAME or GITHUB_ICON
	end

	local branch = vim.b.gitsigns_head
	if not branch or branch == "" then
		local ok, out = pcall(vim.fn.systemlist, { "git", "rev-parse", "--abbrev-ref", "HEAD" })
		if ok and type(out) == "table" and #out > 0 and out[1] ~= "HEAD" then
			branch = out[1]
		end
	end

	if not branch or branch == "" then
		return GITHUB_USERNAME ~= "" and GITHUB_USERNAME or GITHUB_ICON
	end

	return GITHUB_USERNAME ~= "" and (GITHUB_USERNAME .. "/" .. branch) or branch
end

local function file_location_component()
	if vim.fn.expand("%") == "" then
		return ""
	end
	local icon = " "
	local path = vim.fn.expand("%:~:.")
	return icon .. path
end

function M.setup()
	local ok, lualine = pcall(require, "lualine")
	if not ok or not lualine then
		return
	end

	vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
		group = vim.api.nvim_create_augroup("TideLualineStatusline", { clear = true }),
		callback = function()
			local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
			local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine" })
			local updated = vim.tbl_extend("force", statusline or {}, { bg = normal and normal.bg })
			pcall(vim.api.nvim_set_hl, 0, "StatusLine", updated)
		end,
	})

	local default_x = {
		{
			"diagnostics",
			sources = { "nvim_diagnostic" },
			symbols = {
				error = diagnostic_signs.error,
				warn = diagnostic_signs.warn,
				info = diagnostic_signs.info,
				hint = diagnostic_signs.hint,
				other = diagnostic_signs.other,
			},
			colored = true,
			padding = 2,
		},
		{
			current_buffer_lsp,
			padding = 1,
			icon = { " ", color = { fg = C.surface1 } },
			color = { fg = C.text },
		},
		{
			function()
				return " "
			end,
			color = function()
				return state.virtual_diagnostics and { fg = C.green } or { fg = C.surface1 }
			end,
		},
		{
			function()
				return " "
			end,
			color = function()
				return state.zen and { fg = C.green } or { fg = C.surface1 }
			end,
			padding = 0,
		},
		{
			function()
				return " 󰉼 "
			end,
			color = function()
				return state.format_enabled and { fg = C.green } or { fg = C.surface1 }
			end,
			padding = 0,
		},
	}

	local default_z = {
		{
			"location",
			icon = { " ", align = "left" },
			fmt = function(str)
				local fixed_width = 3
				return string.format("%" .. fixed_width .. "s", str)
			end,
		},
		{
			"progress",
			icon = { "", align = "left" },
			separator = { right = "", left = "" },
		},
	}

	local oil_ext = {
		sections = {
			lualine_a = {
				{
					"mode",
					fmt = fmt_mode,
					icon = { "" },
					separator = { right = "", left = "" },
				},
			},
			lualine_b = {},
			lualine_c = {
				{
					short_cwd,
					padding = 0,
					icon = { "", color = { fg = C.surface1 } },
					color = { fg = C.text },
				},
			},
			lualine_x = default_x,
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "oil" },
	}

	local fzf_ext = {
		sections = {
			lualine_a = {
				{
					"mode",
					fmt = fmt_mode,
					icon = { "" },
					separator = { right = " ", left = "" },
				},
			},
			lualine_b = {},
			lualine_c = {
				{
					function()
						return "fzf-lua"
					end,
					color = { fg = C.text },
					icon = { " ", color = { fg = C.surface1 } },
				},
			},
			lualine_x = default_x,
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "fzf" },
	}

	lualine.setup({
		options = {
			theme = build_theme(),
			disabled_filetypes = { "dashboard", "snacks_dashboard" },
			globalstatus = true,
			section_separators = { left = " ", right = " " },
			component_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = {
				{ "mode", fmt = fmt_mode, icon = { "" }, separator = { right = " ", left = "" } },
			},
			lualine_b = {},
			lualine_c = {
				{
					file_location_component,
					color = { fg = C.text },
					padding = 1,
				},
				{
					github_branch_component,
					color = { fg = C.text },
					icon = { "", color = { fg = C.surface1 } },
					padding = 2,
				},
				{
					"diff",
					color = { fg = C.text },
					source = diff_source,
					symbols = { added = " ", modified = " ", removed = " " },
					diff_color = {
						added = { fg = C.green },
						modified = { fg = C.orange },
						removed = { fg = C.red },
					},
					padding = 1,
				},
				{
					recording_component,
					color = recording_color,
					padding = 1,
				},
			},
			lualine_x = default_x,
			lualine_y = {},
			lualine_z = default_z,
		},
		extensions = { fzf_ext, oil_ext },
	})
	vim.schedule(T.clear_statusline_bg)
end

-- rebuild the statusline whenever the theme changes
vim.api.nvim_create_autocmd("User", {
	pattern = "TideThemeChanged",
	callback = function()
		sync_palette()
		if not package.loaded["lualine"] then
			return
		end
		-- run after the ColorScheme handlers (lualine's own, our overrides) have finished
		vim.schedule(function()
			-- drop lualine's cached modules/highlights so the new palette really applies
			for name in pairs(package.loaded) do
				if name == "lualine" or name:match("^lualine%.") then
					package.loaded[name] = nil
				end
			end
			M.setup()
			pcall(function()
				require("lualine").refresh({ scope = "all", place = { "statusline" } })
			end)
			vim.schedule(T.clear_statusline_bg)
		end)
	end,
})

function M.refresh_statusline()
	local ok, lualine = pcall(require, "lualine")
	if ok and lualine and type(lualine.refresh) == "function" then
		pcall(lualine.refresh, { statusline = true })
	end
end

return M
