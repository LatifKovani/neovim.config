-- latif/theme.lua
-- Follows the system-wide theme written by `tide-theme` (~/.config/tide-theme/current.json).
-- On startup it applies that theme; while nvim runs it watches the file and re-applies
-- the colourscheme live whenever you switch themes from the island / `tide-theme apply`.
local M = {}
local uv = vim.uv or vim.loop

local config_home = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
local dir = config_home .. "/tide-theme"
local path = dir .. "/current.json"

-- Palette used by every custom highlight/statusline. Updated IN PLACE on each theme change,
-- so modules may keep a reference to it. Defaults match the setup before theming existed.
M.colors = {
	bg = "#040405",
	island = "#000000",
	fg = "#d8dee9",
	fg_dim = "#60728a",
	accent = "#88c0d0",
	accent2 = "#d89784",
	red = "#bf616a",
	green = "#a3be8c",
	yellow = "#ebcb8b",
	blue = "#81a1c1",
	magenta = "#b48ead",
	cyan = "#88c0d0",
	orange = "#d08770",
}
M.id = ""
M.scheme = "gruvbox-material"

-- scheme id (from the theme json: nvim.scheme) -> how to load it.
-- `plugin` is the lazy.nvim plugin name (see plugins/colorscheme.lua).
local schemes = {
	["gruvbox-material"] = {
		plugin = "gruvbox-material",
		colorscheme = "gruvbox-material",
		setup = function()
			vim.g.gruvbox_material_transparent_background = 1
			vim.g.gruvbox_material_foreground = "mix"
			vim.g.gruvbox_material_background = "hard"
			vim.g.gruvbox_material_ui_contrast = "high"
			vim.g.gruvbox_material_float_style = "bright"
			vim.g.gruvbox_material_statusline_style = "mix"
			vim.g.gruvbox_material_cursor = "auto"
		end,
	},
	["nord"] = {
		plugin = "nord.nvim",
		colorscheme = "nord",
		setup = function()
			require("nord").setup({ transparent = true })
		end,
	},
	["catppuccin"] = {
		plugin = "catppuccin",
		colorscheme = "catppuccin-mocha",
		setup = function()
			require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
		end,
	},
	["tokyonight"] = {
		plugin = "tokyonight.nvim",
		colorscheme = "tokyonight-night",
		setup = function()
			require("tokyonight").setup({ style = "night", transparent = true })
		end,
	},
	["rose-pine"] = {
		plugin = "rose-pine",
		colorscheme = "rose-pine",
		setup = function()
			require("rose-pine").setup({ styles = { transparency = true } })
		end,
	},
	["kanagawa"] = {
		plugin = "kanagawa.nvim",
		colorscheme = "kanagawa-wave",
		setup = function()
			require("kanagawa").setup({ transparent = true })
		end,
	},
	["everforest"] = {
		plugin = "everforest",
		colorscheme = "everforest",
		setup = function()
			vim.g.everforest_background = "hard"
			vim.g.everforest_transparent_background = 1
		end,
	},
	["dracula"] = {
		plugin = "dracula.nvim",
		colorscheme = "dracula",
		setup = function()
			require("dracula").setup({ transparent_bg = true })
		end,
	},
	["ayu"] = {
		plugin = "neovim-ayu",
		colorscheme = "ayu-dark",
		setup = function()
			require("ayu").setup({
				mirage = false,
				overrides = {
					Normal = { bg = "None" },
					NormalFloat = { bg = "None" },
					SignColumn = { bg = "None" },
					ColorColumn = { bg = "None" },
					CursorLine = { bg = "None" },
					CursorColumn = { bg = "None" },
					Folded = { bg = "None" },
					FoldColumn = { bg = "None" },
					VertSplit = { bg = "None" },
				},
			})
		end,
	},
	["github-dark"] = {
		plugin = "github-nvim-theme",
		colorscheme = "github_dark",
		setup = function()
			require("github-theme").setup({
				options = { transparent = true },
			})
		end,
	},
}
M.schemes = schemes

local last_raw = nil

-- Read current.json. Returns true when the theme changed.
function M.load()
	local f = io.open(path, "r")
	if not f then
		return false
	end
	local raw = f:read("*a")
	f:close()
	if not raw or raw == "" or raw == last_raw then
		return false
	end
	local ok, data = pcall(vim.json.decode, raw)
	if not ok or type(data) ~= "table" or type(data.colors) ~= "table" then
		return false -- half-written file; the next change event will retry
	end
	last_raw = raw
	for k, v in pairs(data.colors) do
		M.colors[k] = v
	end
	M.id = data.id or ""
	M.scheme = (data.nvim and data.nvim.scheme) or M.scheme
	return true
end

-- Groups whose background must always be the terminal's (transparent), whatever the colourscheme
-- does. Only groups that already exist are touched, so a lazy plugin that defines its groups later
-- keeps its own foreground/links (the VeryLazy pass below catches those once they exist).
local TRANSPARENT_GROUPS = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"NormalSB",
	"FloatBorder",
	"FloatTitle",
	"SignColumn",
	"FoldColumn",
	"LineNr",
	"EndOfBuffer",
	"WinSeparator",
	"VertSplit",
	"StatusLine",
	"StatusLineNC",
	"WinBar",
	"WinBarNC",
	"TabLineFill",
	-- nvim-tree (the sidebar that was keeping the theme's own bg)
	"NvimTreeNormal",
	"NvimTreeNormalNC",
	"NvimTreeNormalFloat",
	"NvimTreeEndOfBuffer",
	"NvimTreeWinSeparator",
	"NvimTreeStatusLine",
	"NvimTreeStatusLineNC",
}

local function clear_bg(groups)
	for _, g in ipairs(groups) do
		local cur = vim.api.nvim_get_hl(0, { name = g, link = false })
		if next(cur) ~= nil then
			pcall(vim.api.nvim_set_hl, 0, g, vim.tbl_extend("force", cur, { bg = "NONE" }))
		end
	end
end

-- Backgrounds are never themed: only text / accent colours follow the theme.
local function apply_transparency()
	local c = M.colors
	local set = vim.api.nvim_set_hl
	clear_bg(TRANSPARENT_GROUPS)
	for _, g in ipairs({ "ToggleTermNormal", "BufferManagerNormal" }) do
		set(0, g, { bg = "NONE", fg = c.fg })
	end
	for _, g in ipairs({ "ToggleTermBorder", "BufferManagerBorder", "WhichKeyBorder" }) do
		set(0, g, { bg = "NONE", fg = c.fg_dim })
	end
	set(0, "WhichKeyFloat", { bg = "NONE" })
	set(0, "WhichKeyNormal", { bg = "NONE" })
	-- barbecue sets its own groups on ColorScheme, so this also runs after it (see overrides)
	set(0, "barbecue_normal", { bg = "NONE", fg = c.yellow })
	set(0, "barbecue_context", { bg = "NONE", fg = c.yellow })
	set(0, "barbecue_dirname", { bg = "NONE", fg = c.fg_dim })
	set(0, "barbecue_separator", { bg = "NONE", fg = c.fg })
	M.clear_statusline_bg()
end

-- Custom highlights that the colourschemes know nothing about. Re-applied after every :colorscheme.
function M.overrides()
	local c = M.colors
	local set = vim.api.nvim_set_hl
	set(0, "CursorLineNr", { fg = c.red, bold = true })
	set(0, "CurlyBrace", { fg = c.red })
	apply_transparency()
	-- plugins (nvim-tree, barbecue, ...) re-set their groups on ColorScheme too, so go after them
	vim.schedule(apply_transparency)
end

-- The statusline must stay transparent like the terminal: only text and mode colours may change.
function M.clear_statusline_bg()
	local set = vim.api.nvim_set_hl
	pcall(
		set,
		0,
		"StatusLine",
		vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }), { bg = "NONE" })
	)
	pcall(
		set,
		0,
		"StatusLineNC",
		vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false }), { bg = "NONE" })
	)
	local ok, all = pcall(vim.api.nvim_get_hl, 0, {})
	if not ok then
		return
	end
	for name, hl in pairs(all) do
		if name:match("^lualine_[cxy]_") and hl.bg and not hl.link then
			pcall(set, 0, name, vim.tbl_extend("force", hl, { bg = "NONE" }))
		end
	end
end

function M.apply()
	local sc = schemes[M.scheme] or schemes["gruvbox-material"]
	pcall(function()
		require("lazy").load({ plugins = { sc.plugin } })
	end)
	pcall(sc.setup)
	vim.o.background = "dark"
	local ok, err = pcall(vim.cmd.colorscheme, sc.colorscheme)
	if not ok then
		vim.notify(
			("tide-theme: couldn't load '%s' (%s). If the plugin is new, run :Lazy sync and restart."):format(
				sc.colorscheme,
				tostring(err)
			),
			vim.log.levels.WARN
		)
		return
	end
	M.overrides()
	vim.api.nvim_exec_autocmds("User", { pattern = "TideThemeChanged", modeline = false })
end

local watcher, timer
function M.watch()
	if watcher then
		return
	end
	vim.fn.mkdir(dir, "p")
	watcher = uv.new_fs_event()
	timer = uv.new_timer()
	-- watch the directory (not the file) so atomic replaces keep working
	local ok = pcall(function()
		watcher:start(
			dir,
			{},
			vim.schedule_wrap(function(_, fname)
				if fname and fname ~= "current.json" then
					return
				end
				timer:stop()
				timer:start(
					60,
					0,
					vim.schedule_wrap(function()
						if M.load() then
							M.apply()
						end
					end)
				)
			end)
		)
	end)
	if not ok then
		watcher = nil
	end
end

function M.setup()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("TideThemeOverrides", { clear = true }),
		callback = M.overrides,
	})
	-- lazy plugins (nvim-tree, barbecue, ...) define their highlights after startup; catch them once
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = function()
			vim.schedule(apply_transparency)
		end,
	})
	M.load()
	M.apply()
	M.watch()
end

return M
