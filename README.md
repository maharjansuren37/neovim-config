# neovim-config

A lightweight, hand-rolled Neovim config: `vim-plug` (not `lazy.nvim`), no `mason.nvim` — LSP servers/formatters/linters are installed system-wide and picked up automatically by executable name.

## Quick Start

```sh
# 1. Install Neovim ≥ 0.11
#    Arch:          sudo pacman -S neovim
#    Ubuntu/Debian: sudo apt install neovim

# 2. Install the recommended system packages (see "System packages" below)

# 3. Clone this config
cd ~/.config && git clone https://github.com/maharjansuren37/neovim-config.git nvim

# 4. Launch Neovim
nvim

# 5. On first startup:
#    - vim-plug is downloaded automatically and :PlugInstall runs on first VimEnter
#      (if it doesn't fire, run :PlugInstall — bound to <space>P)
#    - blink.cmp downloads a small prebuilt fuzzy-matcher binary (needs network once)
#    - restart nvim
```

Once it's up, try `<space>t` (file explorer), `<space>f` (find files), `<space><space>` (switch buffer), `<space>g` (grep), and `<space>nd` (today's daily note).

On first launch treesitter downloads and compiles its parsers in the background; highlighting gets better after a few seconds.

## Philosophy

- **Plugin manager:** `vim-plug`.
- **No `mason.nvim`.** Install a tool via your system package manager and it's detected by executable name — no config edit needed after.
- **Leader key:** `<space>`.
- Neovim **≥ 0.11** required (uses the native `vim.lsp.enable()`/`vim.lsp.config()` API). Built and tested on **0.12.4**.

## Key Features

- **File explorer:** `<space>t` (nvim-tree)
- **Fuzzy finder:** `<space>f` (find files), `<space>g` (grep)
- **Git integration:** `<space>T` (git status), in-file git signs/hunks
- **LSP support:** Autodetected language servers via executable name
- **Smart completion:** `blink.cmp` with prebuilt binary
- **Auto-formatting:** `conform.nvim` with LSP/formatter fallback
- **Auto-linting:** On write via `nvim-lint`
- **Notes system:** daily notes, wikilinks, backlinks, checkboxes, cross-vault TODOs, autosave
- **Floating terminals:** `<space>z` (shell), `<space>H` (htop) — toggles, the shell keeps running
- **Workspace bookmarks:** `<space>Fh/Fc/Fl/Ff` (home/.config/.local/src/parent)

## Directory layout

```
init.lua                        -- vim-plug bootstrap, Plug list, load order
lua/
├── config/
│   ├── options.lua              -- vim.opt settings
│   ├── mappings.lua             -- all keymaps
│   ├── autocmd.lua              -- autocommands
│   ├── notes.lua                -- note-taking: daily/new/link/backlinks/todos/checkboxes
│   └── term.lua                 -- floating terminal (toggleable, persistent shell)
└── plugins/
    ├── which-key.lua            -- keybind popup + descriptions
    ├── fzf-lua.lua               -- fuzzy finder / grep
    ├── treesitter.lua           -- syntax/indent/folds
    ├── nvim-tree.lua            -- file explorer
    ├── render-markdown.lua      -- inline markdown rendering
    ├── gitsigns.lua             -- git gutter signs + hunk actions
    ├── blink.lua                -- completion engine
    ├── lsp.lua                  -- native LSP enablement + LspAttach keymaps
    ├── conform.lua              -- formatting
    └── lint.lua                 -- linting (linters_by_ft)
```

`config/notes.lua` points at a notes vault outside this repo (defaults to `~/para/02-areas/hnoteverse` — change `M.dir` to your own path).

## Keybinding reference

Leader = `<space>`.

**General**
| key | action |
|---|---|
| `<leader>?` | search all keymaps (fzf) |
| `<leader>R` | reload config (clears `config.*`/`plugins.*` from `package.loaded`, re-sources `init.lua`) |
| `<leader>P` | `:PlugInstall` |
| `<leader>pt` | toggle light/dark background |
| `<leader>u` | open URL/path under cursor (`vim.ui.open`) |
| `<leader>z` | floating terminal (shell), `<C-q>` hides it |
| `<leader>H` | floating terminal running `htop` |
| `<leader>N` | toggle relative line numbers (overrides the dynamic auto-toggle below) |
| `<C-s>` | write file (normal, insert and visual mode; stays in insert) |
| `<Esc>` | clear search highlight |

**Files** (`config/files.lua` — prompts are prefilled, paths are cwd-relative)
| key | action |
|---|---|
| `<leader>on` | new file (missing directories are created) |
| `<leader>oN` | new directory |
| `<leader>or` | rename file in place (LSP-aware: updates imports when a server is attached) |
| `<leader>om` | move file (full path editable, so it renames too) |
| `<leader>oc` | duplicate file (defaults to `name-copy.ext`, auto-numbered) |
| `<leader>oD` | delete file (asks first, then drops the buffer) |
| `<leader>oy` / `<leader>oY` | copy relative / absolute path to clipboard |
| `<leader>ot` / `<leader>od` | copy file name / containing directory |
| `<leader>ox` | `chmod +x` current file |
| `<leader>oe` | reveal current file in nvim-tree |
| `<leader>oo` | open current file with the desktop handler |

**Buffers/windows**
| key | action |
|---|---|
| `<S-l>` / `<S-h>` | next/previous buffer |
| `<leader>q` | close buffer |
| `<leader>bn` | new empty buffer (`:enew`) |
| `<leader>bd` / `<leader>bD` | close buffer / close discarding changes |
| `<leader>bo` | close every *other* buffer |
| `<leader>bX` | close all buffers |
| `<leader>vs` | vsplit |
| `<leader>w` | cycle window (`<C-w>w`) |
| `<leader>W` | toggle line wrap |
| `<leader>t` | toggle file explorer (nvim-tree) |
| `<C-h/j/k/l>` | move to window left/down/up/right |

**Editing**
| key | action |
|---|---|
| `<C-d>` / `<C-u>` | half page down/up, cursor re-centered |
| `n` / `N` | next/prev match, re-centered and folds opened |
| `j` / `k` | move by *screen* line when wrapped (`5j` still moves 5 real lines) |
| `<` / `>` (visual) | indent/outdent and keep the selection |
| `J` / `K` (visual) | move the selected lines down/up |
| `p` (visual) | paste over a selection without clobbering the register |

**Search (fzf-lua)**
| key | action |
|---|---|
| `<leader>f` | find files (cwd) |
| `<leader><leader>` | switch buffer |
| `<leader>g` | live grep (cwd); in visual mode, grep the selection |
| `<leader>G` | grep word under cursor |
| `<leader>Fh` / `Fc` / `Fl` / `Ff` | find files in `~`, `~/.config`, `~/.local/src`, parent dir |
| `<leader>Fr` | resume last fzf-lua picker |
| `<leader>Fo` | recent files |
| `<leader>Fb` | fuzzy-search lines in the current buffer |
| `<leader>Fk` | search keymaps |
| `<leader>FH` | search help tags |
| `<leader>Fd` | workspace diagnostics |

**Notes**
| key | action |
|---|---|
| `<leader>nf` | find a note |
| `<leader>ng` | grep notes |
| `<leader>nd` | open/create today's daily note (seeded with Log + Tasks sections) |
| `<leader>ny` | yesterday's daily note |
| `<leader>nw` | new note (prompts for title, slugifies it) |
| `<leader>ni` | open the vault's `index.md` |
| `<leader>nl` | pick a note and insert a `[[wikilink]]` to it (also `<C-l>` in insert mode) |
| `<leader>nt` | every unchecked `- [ ]` task across the vault |
| `<leader>nb` | notes that `[[link]]` back to this one |
| `<leader>nc` | toggle `- [ ]` / `- [x]` on the current line (adds a checkbox if there is none) |
| `<CR>` | in markdown: follow the `[[wikilink]]` under the cursor, creating the note if new |

Notes in the vault **autosave** on `InsertLeave`/`FocusLost`/`BufLeave`, and markdown
buffers get spell, wrap, 2-space list indent and automatic list continuation on `<CR>`/`o`.
Format-on-save deliberately skips the vault: prettier rewrapping a note on every
autosave moves text out from under the cursor.

**Git**
| key | action |
|---|---|
| `<leader>T` | fzf-lua git status picker |
| `<leader>hc` / `hf` | git log for the repo / for this file |
| `]c` / `[c` | next/prev git hunk |
| `<leader>hs` / `hr` | stage / reset hunk (also works in visual mode) |
| `<leader>hS` / `hR` | stage / reset whole buffer |
| `<leader>hu` | undo staged hunk |
| `<leader>hp` | preview hunk diff |
| `<leader>hb` | full blame for current line |
| `<leader>hB` | toggle inline current-line blame |
| `<leader>hd` | diff against index |
| `ih` | hunk text object (e.g. `dih`, `vih`) |

**LSP** (buffer-local, only active once a server attaches — see `plugins/lsp.lua`)
| key | action |
|---|---|
| `gd` / `gD` | goto definition / declaration |
| `gr` | references (fzf-lua) |
| `gi` | goto implementation |
| `K` | hover |
| `<leader>rn` | rename |
| `<leader>ca` | code action |
| `<leader>ss` / `sw` | document / workspace symbols |
| `<leader>e` | line diagnostics float |
| `]d` / `[d` | next/prev diagnostic |

**Format/Lint**
| key | action |
|---|---|
| `<leader>lf` | format buffer or selection (`conform.nvim`, falls back to LSP formatting) |
| `<leader>lF` | toggle format-on-save |
| *(automatic)* | format on save, **only** when a formatter for the filetype is installed |
| *(automatic)* | lint runs on every `BufWritePost` via `nvim-lint`, per `linters_by_ft` |

## How to extend

- **Add a plugin:** add `Plug('author/repo')` in `init.lua`'s Plug block, add `require("plugins.name")` near the bottom, create `lua/plugins/name.lua`, then `<leader>P` (`:PlugInstall`). If `init.lua` errors on a plugin that isn't downloaded yet, comment out its `require` line, run `:PlugInstall`, then uncomment it.
- **Add an LSP server:** add one line to the `servers` table in `lua/plugins/lsp.lua` (`lspconfig_name = "executable-name"`) and install the executable.
- **Add a formatter/linter:** add a filetype entry to `formatters_by_ft` (`plugins/conform.lua`) or `linters_by_ft` (`plugins/lint.lua`).
- **Reload after any config edit:** `<leader>R`, no restart needed.

## Known caveats / deliberate decisions

- **No `mason.nvim`** — a deliberate lightweight choice; tool installation is on you via the system package manager.
- **`format_on_save` is on, but self-disabling.** `conform.lua` checks `list_formatters_to_run`
  before every write and skips formatting when no formatter for that filetype is installed, so a
  missing `prettierd` never breaks a save. Turn it off for a session with `<leader>lF`, or per
  buffer with `:lua vim.b.disable_autoformat = true`.
- **Statusline and tabline are hand-rolled** in `config/options.lua` (`_G.statusline`,
  `_G.tabline_buffers`) rather than pulling in lualine/bufferline — `laststatus=3` gives one
  global bar showing file, diagnostics count, git branch, filetype and position.
- **Watch for leader-key prefix collisions**: if `<leader>x` is already a complete mapping, adding `<leader>xy` later makes Neovim wait out `timeoutlen` before firing `<leader>x` alone. Check whether a letter is already a leaf before nesting more keys under it.

## System packages (Arch — all in official repos, no AUR needed)

```sh
sudo pacman -S fd bat htop xdg-utils tree-sitter-cli \
  lua-language-server stylua \
  pyright ruff \
  typescript-language-server prettier eslint_d \
  bash-language-server shellcheck shfmt \
  marksman \
  clang
```

| package | why |
|---|---|
| `fd`, `bat` | fzf-lua file search/preview quality (works without them, just slower/plainer) |
| `tree-sitter-cli` | **required** by nvim-treesitter's `main` branch to compile parsers. Without it only Neovim's bundled parsers (c, lua, markdown, query, vim, vimdoc) are available and `:TSInstallHelp` explains why |
| `htop`, `xdg-utils` | back `<leader>H` (htop terminal) and `<leader>u` (open url/path under cursor) |
| `lua-language-server`, `stylua` | Lua LSP + formatter — used for editing this very config |
| `pyright`, `ruff` | Python: types/hover/goto-def (pyright) + lint & format (ruff) |
| `typescript-language-server`, `prettier`, `eslint_d` | JS/TS LSP, formatter, linter |
| `bash-language-server`, `shellcheck`, `shfmt` | shell LSP, linter, formatter |
| `marksman` | markdown/wikilink LSP — useful inside a notes vault |
| `clang` | C/C++: provides **both** `clangd` (LSP) and `clang-format` (formatter) via `clang-tools-extra` |

On a non-Arch distro, translate package names — e.g. Debian/Ubuntu often needs `npm i -g typescript-language-server bash-language-server prettier` and similar for `eslint_d` instead of a direct apt package.

Nothing above is required to run this config — every server/formatter/linter is only enabled if its executable is found on `$PATH` (see `lua/plugins/lsp.lua`, `conform.lua`, `lint.lua`).

## Plugin inventory

| plugin | purpose | config |
|---|---|---|
| `folke/which-key.nvim` | shows available keybinds in a popup | `plugins/which-key.lua` |
| `ibhagwan/fzf-lua` | fuzzy find files/grep/git/LSP pickers | `plugins/fzf-lua.lua` |
| `nvim-treesitter/nvim-treesitter` | syntax highlight, indent, folds | `plugins/treesitter.lua` |
| `nvim-tree/nvim-tree.lua` | file explorer sidebar | `plugins/nvim-tree.lua` |
| `MeanderingProgrammer/render-markdown.nvim` | inline-rendered markdown (headings, checkboxes, callouts) | `plugins/render-markdown.lua` |
| `lewis6991/gitsigns.nvim` | gutter diff signs, hunk stage/reset/blame | `plugins/gitsigns.lua` |
| `neovim/nvim-lspconfig` | default LSP server configs (data only — no `.setup()` calls) | `plugins/lsp.lua` |
| `saghen/blink.cmp` | completion engine, prebuilt binary | `plugins/blink.lua` |
| `stevearc/conform.nvim` | formatting | `plugins/conform.lua` |
| `mfussenegger/nvim-lint` | linting, run from `config/autocmd.lua`'s `BufWritePost` | `plugins/lint.lua` |
