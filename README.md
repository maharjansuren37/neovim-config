# neovim-config

A lightweight, hand-rolled Neovim config: `vim-plug` (not `lazy.nvim`), no `mason.nvim` — LSP servers/formatters/linters are installed system-wide and picked up automatically by executable name.

## Philosophy

- **Plugin manager:** `vim-plug`.
- **No `mason.nvim`.** Install a tool via your system package manager and it's detected by executable name — no config edit needed after.
- **Leader key:** `<space>`.
- Neovim **≥ 0.11** required (uses the native `vim.lsp.enable()`/`vim.lsp.config()` API). Built and tested on **0.12.4**.

## Directory layout

```
init.lua                        -- vim-plug bootstrap, Plug list, load order
lua/
├── config/
│   ├── options.lua              -- vim.opt settings
│   ├── mappings.lua             -- all keymaps
│   ├── autocmd.lua              -- autocommands
│   ├── notes.lua                -- lightweight note-taking (find/grep/daily/new)
│   └── term.lua                 -- floating terminal helper
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

## Setup on a new machine

1. Install Neovim ≥ 0.11.
2. Clone this repo to `~/.config/nvim`.
3. Launch `nvim` — `init.lua` bootstraps `vim-plug` itself (downloads `plug.vim`, auto-runs `PlugInstall` on first `VimEnter`). If that doesn't fire, run `:PlugInstall` manually (bound to `<leader>P`).
4. `blink.cmp` downloads a small prebuilt fuzzy-matcher binary the first time it loads — needs network access once, no `cargo`/Rust toolchain required. Give it a few seconds on first startup before typing.
5. Install the system packages below.
6. Restart `nvim`.

## Recommended system packages (Arch — all in official repos, no AUR needed)

```sh
sudo pacman -S fd bat htop xdg-utils \
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

## Keybinding reference

Leader = `<space>`.

**General**
| key | action |
|---|---|
| `<leader>cd` | open netrw-style `:Ex` at current dir |
| `<leader>R` | reload config (clears `config.*`/`plugins.*` from `package.loaded`, re-sources `init.lua`) |
| `<leader>P` | `:PlugInstall` |
| `<leader>p` | toggle light/dark background |
| `<leader>u` | open URL/path under cursor (`vim.ui.open`) |
| `<leader>z` | floating terminal (shell) |
| `<leader>H` | floating terminal running `htop` |
| `<leader>x` | `chmod +x` current file |
| `<leader>d` | duplicate current file (`name-copy.ext`, auto-numbered if it exists) |
| `<leader>nn` | toggle relative line numbers (overrides the dynamic auto-toggle below) |

**Buffers/windows**
| key | action |
|---|---|
| `<S-l>` / `<S-h>` | next/previous buffer |
| `<leader>q` / `<leader>Q` | close buffer / force-close |
| `<leader>U` | close all buffers |
| `<leader>vs` | vsplit + open next buffer |
| `<leader>w` | cycle window (`<C-w>w`) |
| `<leader>W` | toggle line wrap |
| `<leader>t` | toggle file explorer (nvim-tree) |

**Search (fzf-lua)**
| key | action |
|---|---|
| `<leader>f` | find files (cwd) |
| `<leader>Fh` / `Fc` / `Fl` / `Ff` | find files in `~`, `~/.config`, `~/.local/src`, parent dir |
| `<leader>Fr` | resume last fzf-lua search |
| `<leader>g` | grep (cwd) |
| `<leader>G` | grep word under cursor |

**Notes**
| key | action |
|---|---|
| `<leader>nf` | find a note |
| `<leader>ng` | grep notes |
| `<leader>nd` | open/create today's daily note |
| `<leader>nw` | new note (prompts for title) |

**Git**
| key | action |
|---|---|
| `<leader>T` | fzf-lua git status picker |
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
| `<leader>lf` | format buffer (`conform.nvim`, falls back to LSP formatting) |
| *(automatic)* | lint runs on every `BufWritePost` via `nvim-lint`, per `linters_by_ft` |

## How to extend

- **Add a plugin:** add `Plug('author/repo')` in `init.lua`'s Plug block, add `require("plugins.name")` near the bottom, create `lua/plugins/name.lua`, then `<leader>P` (`:PlugInstall`). If `init.lua` errors on a plugin that isn't downloaded yet, comment out its `require` line, run `:PlugInstall`, then uncomment it.
- **Add an LSP server:** add one line to the `servers` table in `lua/plugins/lsp.lua` (`lspconfig_name = "executable-name"`) and install the executable.
- **Add a formatter/linter:** add a filetype entry to `formatters_by_ft` (`plugins/conform.lua`) or `linters_by_ft` (`plugins/lint.lua`).
- **Reload after any config edit:** `<leader>R`, no restart needed.

## Known caveats / deliberate decisions

- **No `mason.nvim`** — a deliberate lightweight choice; tool installation is on you via the system package manager.
- **`format_on_save` is intentionally OFF** in `conform.lua`, to avoid save-time errors on machines without the relevant formatters installed. Add:
  ```lua
  format_on_save = { timeout_ms = 500, lsp_fallback = true },
  ```
  inside the `require("conform").setup({...})` call once you've installed formatters for the languages you use.
- **Watch for leader-key prefix collisions**: if `<leader>x` is already a complete mapping, adding `<leader>xy` later makes Neovim wait out `timeoutlen` before firing `<leader>x` alone. Check whether a letter is already a leaf before nesting more keys under it.
