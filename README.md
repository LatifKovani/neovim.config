# 🌑 Neovim Config

> A fast, minimal Neovim setup built for modern web development — TypeScript, React, Python, and Lua. Follows your system-wide theme and re-colours itself live.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-brightgreen?style=flat-square&logo=neovim)
![Lua](https://img.shields.io/badge/Config-Lua-blue?style=flat-square&logo=lua)
![License](https://img.shields.io/badge/License-MIT-orange?style=flat-square)

---

## 📸 Showcase

> Dashboard on startup

![Dashboard](./assets/dashboard.png)

> Code editing with LSP diagnostics

![Editing](./assets/editing2.png)

> Live theme switching (same Neovim session, no restart)

![Theme switching](./assets/theme-switcher.png)

---

## ⚡ Requirements

- Neovim **0.10+**
- [fzf](https://github.com/junegunn/fzf) — required for fzf-lua picker
- [git](https://git-scm.com/)
- A [Nerd Font](https://www.nerdfonts.com/) — for icons
- Node.js — for TypeScript LSP
- Python 3 — for Python LSP
- `prettierd`, `stylua`, `eslint_d` — installed automatically via Mason
- _(optional)_ `tide-theme` — system-wide theme switcher that drives the colourscheme (see [Theme Switcher](#-theme-switcher)). Without it, the config falls back to gruvbox-material.

---

## 📦 Installation

```bash
# Back up your existing config first
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone https://github.com/LatifKovani/nvim ~/.config/nvim

# Install fzf (Arch)
sudo pacman -S fzf

# Launch Neovim — lazy.nvim will auto-install all plugins
nvim
```

On first launch, run `:Lazy sync` to ensure everything is installed, then restart Neovim.

---

## 🎨 Theme Switcher

Neovim doesn't pick its own colourscheme — it **follows the system-wide theme** managed by `tide-theme`. Switch the theme from the Tide Island theme picker (or from the terminal) and every open Neovim instance re-colours itself instantly, alongside kitty, tmux, hyprlock and the rest of the desktop.

```bash
tide-theme apply nord      # apply a specific theme
tide-theme next            # cycle forward
tide-theme prev            # cycle backward
tide-theme list --json     # list available themes
```

### How it works

1. `tide-theme` writes the active theme to `~/.config/tide-theme/current.json` (palette + which Neovim scheme to use).
2. On startup, `lua/latif/theme.lua` reads that file, loads the matching colourscheme and applies it.
3. While Neovim runs, it **watches `~/.config/tide-theme/`** (libuv `fs_event`, debounced) and re-applies the colourscheme whenever `current.json` changes. No restart needed.
4. After every colourscheme change, custom highlights are re-applied and a `User TideThemeChanged` autocmd fires so other modules (like lualine) can rebuild themselves.

### Supported themes

| Theme            | Neovim colourscheme                                                   |
| ---------------- | --------------------------------------------------------------------- |
| Nord             | [nord.nvim](https://github.com/gbprod/nord.nvim)                      |
| Gruvbox Material | [gruvbox-material](https://github.com/sainnhe/gruvbox-material)       |
| Catppuccin Mocha | [catppuccin](https://github.com/catppuccin/nvim) (`mocha`)            |
| Tokyo Night      | [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) (`night`) |
| Rosé Pine        | [rose-pine](https://github.com/rose-pine/neovim)                      |
| Kanagawa         | [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) (`wave`)    |
| Everforest       | [everforest](https://github.com/sainnhe/everforest) (hard)            |
| Dracula          | [dracula.nvim](https://github.com/Mofiqul/dracula.nvim)               |

All schemes run with a **transparent background**, so the terminal's opacity and wallpaper always show through. Only gruvbox-material is loaded eagerly; every other scheme is lazy-loaded the first time you switch to it.

### What follows the theme

- **Colourscheme** — swapped live with transparency enforced per scheme
- **Lualine** — palette is re-synced and the statusline is rebuilt on every theme change; its background stays transparent
- **Custom highlights** — `CursorLineNr`, the red curly braces (`{}`), toggleterm, buffer manager, which-key and barbecue breadcrumbs are all re-coloured from the theme palette
- **Palette access** — `require("latif.theme").colors` always holds the current palette (`bg`, `fg`, `fg_dim`, `accent`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `orange`, …) and is updated in place, so any module can use it

### Hooking into theme changes

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "TideThemeChanged",
  callback = function()
    local c = require("latif.theme").colors
    -- re-apply your own highlights using c.bg, c.fg, c.accent, ...
  end,
})
```

### Adding a new theme

1. Add a JSON file to `~/.config/tide-theme/themes/` with a `colors` table and `"nvim": { "scheme": "<id>" }`.
2. If it needs a new colourscheme plugin, add it (lazy) to `lua/latif/plugins/colorscheme.lua`.
3. Register the scheme in the `schemes` table in `lua/latif/theme.lua` (plugin name, colourscheme name and a `setup` function that enables transparency).
4. Run `:Lazy sync`, then `tide-theme apply <id>`.

### Notes

- If `current.json` is missing, Neovim falls back to **gruvbox-material** with the default palette.
- If a scheme fails to load (e.g. a newly added plugin isn't installed yet), you get a warning — run `:Lazy sync` and restart.
- Half-written files are ignored; the next change event retries automatically.

---

## 🖌️ Colorscheme

Default / fallback: **[gruvbox-material](https://github.com/sainnhe/gruvbox-material)** with a hard dark background, transparent window, and mix foreground palette. Curly braces are highlighted in a custom red for better visibility (the red follows the active theme).

The active scheme is chosen by the system theme — see [Theme Switcher](#-theme-switcher).

---

## 🔌 Plugins

### Core

| Plugin                                                    | Purpose                            |
| --------------------------------------------------------- | ---------------------------------- |
| [lazy.nvim](https://github.com/folke/lazy.nvim)           | Plugin manager                     |
| [snacks.nvim](https://github.com/folke/snacks.nvim)       | Notifications, dashboard, input UI |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap hints                       |
| [noice.nvim](https://github.com/folke/noice.nvim)         | Cmdline popup UI                   |

### Colourschemes (driven by the theme switcher)

| Plugin                                                          | Theme            |
| --------------------------------------------------------------- | ---------------- |
| [gruvbox-material](https://github.com/sainnhe/gruvbox-material) | Gruvbox Material |
| [nord.nvim](https://github.com/gbprod/nord.nvim)                | Nord             |
| [catppuccin](https://github.com/catppuccin/nvim)                | Catppuccin Mocha |
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim)     | Tokyo Night      |
| [rose-pine](https://github.com/rose-pine/neovim)                | Rosé Pine        |
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)       | Kanagawa         |
| [everforest](https://github.com/sainnhe/everforest)             | Everforest       |
| [dracula.nvim](https://github.com/Mofiqul/dracula.nvim)         | Dracula          |

### LSP & Completion

| Plugin                                                                                   | Purpose                  |
| ---------------------------------------------------------------------------------------- | ------------------------ |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                               | LSP configuration        |
| [mason.nvim](https://github.com/mason-org/mason.nvim)                                    | LSP/tool installer       |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim)                | Mason + lspconfig bridge |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                                          | Completion engine        |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip)                                           | Snippet engine           |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)                     | Snippet collection       |
| [tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim) | Inline diagnostics       |

### Finder

| Plugin                                         | Purpose                           |
| ---------------------------------------------- | --------------------------------- |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | Fuzzy finder for files, grep, LSP |

### Formatting & Linting

| Plugin                                                   | Purpose         |
| -------------------------------------------------------- | --------------- |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Auto formatting |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint)   | Linting         |

### Git

| Plugin                                                      | Purpose             |
| ----------------------------------------------------------- | ------------------- |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in gutter |
| [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)    | LazyGit integration |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim)  | Diff viewer         |
| [vim-fugitive](https://github.com/tpope/vim-fugitive)       | Git commands        |

### UI

| Plugin                                                                          | Purpose                                  |
| ------------------------------------------------------------------------------- | ---------------------------------------- |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)                    | Statusline (re-themes live, transparent) |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim)                       | Winbar breadcrumbs                       |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)                     | File explorer                            |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides                            |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)               | Highlighted TODO comments                |
| [trouble.nvim](https://github.com/folke/trouble.nvim)                           | Diagnostics list                         |

### Editing

| Plugin                                                        | Purpose               |
| ------------------------------------------------------------- | --------------------- |
| [nvim-surround](https://github.com/kylechui/nvim-surround)    | Surround text objects |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs)    | Auto close brackets   |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim)      | Smart commenting      |
| [substitute.nvim](https://github.com/gbprod/substitute.nvim)  | Quick substitution    |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Terminal manager      |
| [tmux.nvim](https://github.com/aserowy/tmux.nvim)             | Tmux navigation       |

---

## ⌨️ Keymaps

**Leader key: `Space`**

### Files & Search

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>ff` | Find files             |
| `<leader>fr` | Recent files           |
| `<leader>fs` | Live grep              |
| `<leader>fc` | Grep word under cursor |

### LSP

| Key          | Action                     |
| ------------ | -------------------------- |
| `gd`         | Go to definition           |
| `gD`         | Go to declaration          |
| `gR`         | Show references            |
| `gi`         | Show implementations       |
| `gt`         | Show type definitions      |
| `K`          | Hover documentation        |
| `<leader>la` | Code actions               |
| `<leader>ln` | Rename symbol              |
| `<leader>ls` | Restart LSP                |
| `[d` / `]d`  | Previous / next diagnostic |

### Git

| Key          | Action               |
| ------------ | -------------------- |
| `<leader>gl` | Open LazyGit         |
| `<leader>Gp` | Preview hunk         |
| `<leader>Gs` | Stage hunk           |
| `<leader>Gr` | Reset hunk           |
| `<leader>Gd` | Diff HEAD            |
| `]]` / `[[`  | Next / previous hunk |

### Buffers

| Key          | Action          |
| ------------ | --------------- |
| `<Tab>`      | Switch buffers  |
| `<leader>bn` | Next buffer     |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete buffer   |
| `<leader>bm` | Buffer manager  |

### Terminal

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>tt` | New float terminal      |
| `<leader>tF` | Toggle float terminal   |
| `<leader>th` | New horizontal terminal |
| `<leader>tv` | New vertical terminal   |
| `<Ctrl-\>`   | Toggle terminal         |

### Splits & Tabs

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>sv` | Split vertical   |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Equalize splits  |
| `<leader>sx` | Close split      |
| `<leader>to` | New tab          |
| `<leader>tx` | Close tab        |

### Notifications

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>nh` | Notification history  |
| `<leader>nd` | Dismiss notifications |

### Diagnostics

| Key          | Action                |
| ------------ | --------------------- |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics  |
| `<leader>xt` | Todo list             |

### Surround

| Key          | Action                 |
| ------------ | ---------------------- |
| `ysiw"`      | Wrap word with `"`     |
| `ds"`        | Delete surrounding `"` |
| `cs"'`       | Change `"` to `'`      |
| `S` (visual) | Surround selection     |

---

## 🧑‍💻 LSP Servers

Automatically installed via Mason:

- `ts_ls` — TypeScript / JavaScript
- `pyright` — Python
- `lua_ls` — Lua
- `html` — HTML
- `cssls` — CSS / SCSS
- `tailwindcss` — Tailwind CSS
- `emmet_language_server` — Emmet

## 🖋️ Formatters & Linters

Automatically installed via Mason:

- `prettierd` — JS, TS, HTML, CSS, JSON, YAML, Markdown
- `stylua` — Lua
- `black` + `isort` — Python
- `eslint_d` — JS/TS linting
- `pylint` — Python linting
