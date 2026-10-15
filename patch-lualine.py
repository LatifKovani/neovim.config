#!/usr/bin/env python3
import pathlib
import re
import sys

p = pathlib.Path.home() / ".config/nvim/lua/latif/core/lualine.lua"
src = p.read_text(encoding="utf-8")
pathlib.Path(str(p) + ".bak").write_text(src, encoding="utf-8")


def swap(pattern, repl, text, label):
    new, n = re.subn(pattern, lambda m: repl, text, count=1, flags=re.S)
    if n != 1:
        sys.exit(f"patch failed, couldn't find: {label}")
    return new


PALETTE = """-- Terminal background (same as kitty / tmux). Text on coloured blocks uses it, so the
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
"""

BUILD_THEME = """local function build_theme()
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
"""

RELOAD = """-- rebuild the statusline whenever the theme changes
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
"""

src = swap(
    r'(?:-- Terminal background.*?\nlocal TERMINAL_BG = "[^"]*"\n\n)?-- Palette follows the active tide-theme.*?\nsync_palette\(\)\n',
    PALETTE,
    src,
    "palette block",
)
src = swap(
    r"local function build_theme\(\).*?\nend\n", BUILD_THEME, src, "build_theme()"
)
src = swap(
    r'-- rebuild the statusline whenever the theme changes\nvim\.api\.nvim_create_autocmd\("User", \{.*?\n\}\)\n',
    RELOAD,
    src,
    "TideThemeChanged autocmd",
)

p.write_text(src, encoding="utf-8")
print("patched", p, "(backup: lualine.lua.bak)")
