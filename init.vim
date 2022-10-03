" nvim plugin file: ~/.config/nvim/nvim-plugins.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
set runtimepath+=~/.local/share/nvim/site/autoload
let &packpath = &runtimepath
source ~/.vim/vimrc
" keep nvim from hanging on C-z on windows
if has('win32') || has('win64')
  nmap <C-z> <Nop>
endif
" neovide
if exists('g:neovide')
  set guifont=Fira\ Code:h8
  let g:neovide_transparency=0.8
endif
let g:UltiSnipsSnippetDirectories = ["~/.vim/UltiSnips/"]
lua << EOF
  -- LSP stuff
  local nvim_lsp = require('lspconfig')
  local langs = {
    hls = {},
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          procMacro = { enable = false }
        }
      }
    },
    clangd = {},
    texlab = {
      settings = {
        args = {"-pdf", "--shell-escape"}
      }
    },
    erlangls = {},
    eslint = {},
    pylsp = {}
  }

  local custom_attach = function(client, bufnr_)
    bufnr = 0
    local function map(mode, key, value)
      vim.keymap.set(mode,key,value,{noremap = true, silent = true, buffer = bufnr})
    end
    local function nmap(key, value) map('n', key, value) end
    local function set_option(opt, val)
      vim.api.nvim_buf_set_option(bufnr_, opt, val)
    end
    set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    nmap('gd', vim.lsp.buf.definition)
    nmap('gD', vim.lsp.buf.type_definition)
    nmap('gr', vim.lsp.buf.references)
    nmap('gR', vim.lsp.buf.rename)
    map('v', 'K', vim.lsp.buf.hover)
    nmap('K',  vim.lsp.buf.hover)
    nmap('ga', vim.lsp.buf.code_action)
    nmap('=f', vim.lsp.buf.formatting)
    nmap('].', vim.diagnostic.goto_next)
    nmap('[.', vim.diagnostic.goto_prev)
    nmap('<leader>i', function () vim.diagnostic.open_float(0, { scope = "line", padding="single" }) end)
    nmap('<leader>d', vim.lsp.buf.code_action)
    nmap('<leader>q', vim.diagnostic.setqflist)
  end

  for lang,opts in pairs(langs) do
    nvim_lsp[lang].setup(opts)
    nvim_lsp[lang].setup { on_attach = custom_attach }
  end

  -- tree sitter stuff
  require'nvim-treesitter.configs'.setup {
    ensure_installed = { "lua", "python", "javascript", "elixir", "haskell",
                         "cpp", "typescript", "tsx", "regex", "rust" },
    highlight = { enable = true },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
        selection_modes = {
          ['@function.outer'] = 'V',
          ['@class.outer'] = 'V',
        },
        include_surrounding_whitespace = true,
      },
    },
  }

  -- telescope stuff
  telescope = require('telescope')
  tele_actions = require('telescope.actions')
  telescope.setup({
    defaults = {
      history = {

      },
      mappings = {
        i = {
          ["<C-Down>"] = tele_actions.cycle_history_next,
          ["<C-Up>"] = tele_actions.cycle_history_prev,
        },
      },
    },
  })
  telescope.load_extension('fzf')
  telescope.load_extension('ultisnips')
  telescope.load_extension('hoogle')
  telescope.load_extension('harpoon')

EOF
