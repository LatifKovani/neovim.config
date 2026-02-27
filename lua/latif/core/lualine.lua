local M = {}

local function get_recording()
	local ok, rec = pcall(vim.fn.reg_recording)
	return ok and rec ~= ""
end

local function recording_component()
	return get_recording() and "" or ""
end

local function recording_color()
	return get_recording() and { fg = "#BF616A" } or { fg = "#60728A" }
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

-- Nordic-inspired palette
local C = {
	bg = "#040405",
	surface0 = "#040405",
	surface1 = "#BBC3D4",
	surface2 = "#040405",
	text = "#60728A",
	comment = "#616E88",
	blue = "#81A1C1",
	cyan = "#88C0D0",
	green = "#A3BE8C",
	red = "#BF616A",
	violet = "#B48EAD",
	orange = "#D79784",
}

local nordic = {
	normal = {
		a = { fg = C.bg, bg = C.orange },
		b = { fg = C.text, bg = C.surface1 },
		c = { fg = C.text, bg = C.bg },
		z = { fg = C.bg, bg = C.orange },
	},
	insert = { a = { fg = C.bg, bg = C.green }, z = { fg = C.bg, bg = C.green } },
	visual = { a = { fg = C.bg, bg = C.cyan }, z = { fg = C.bg, bg = C.cyan } },
	replace = { a = { fg = C.bg, bg = C.red }, z = { fg = C.bg, bg = C.red } },
	command = { a = { fg = C.bg, bg = C.violet }, z = { fg = C.bg, bg = C.violet } },
	inactive = {
		a = { fg = C.text, bg = C.surface2 },
		b = { fg = C.text, bg = C.surface2 },
		c = { fg = C.text, bg = C.surface2 },
		z = { fg = C.text, bg = C.surface2 },
	},
}

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
				return "󰉼 "
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
				local fixed_width = 7
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

	local telescope_ext = {
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
						return "Telescope"
					end,
					color = { fg = C.text },
					icon = { " ", color = { fg = C.surface1 } },
				},
			},
			lualine_x = default_x,
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "TelescopePrompt" },
	}

	lualine.setup({
		options = {
			theme = nordic,
			disabled_filetypes = { "dashboard" },
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
					color = { fg = "#60728A" },
					icon = { "", color = { fg = "#BBC3D4" } },
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
		extensions = { telescope_ext, oil_ext },
	})
end

function M.refresh_statusline()
	local ok, lualine = pcall(require, "lualine")
	if ok and lualine and type(lualine.refresh) == "function" then
		pcall(lualine.refresh, { statusline = true })
	end
end

return M
