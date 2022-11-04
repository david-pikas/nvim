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

nnoremap [<C-I> :TSTextobjectGotoPreviousStart @
vnoremap [<C-I> :TSTextobjectGotoPreviousStart @

nnoremap ]<C-I> :TSTextobjectGotoNextEnd @
vnoremap ]<C-I> :TSTextobjectGotoNextEnd @

function! PopUpMenuExists(name)
    return 0 < len(menu_get('PopUp')[0].submenus->filter({i,v -> get(v, "name") == a:name}))
endfunc

if PopUpMenuExists("How-to disable mouse")
    " remove how to disable menu item
    unmenu PopUp.How-to\ disable\ mouse
endif
" add (tag based) go to definition
menu PopUp.Go\ to\ &definition <C-]>

function! LspMenu()
  if luaeval('0 < #vim.lsp.buf_get_clients()')
    " add (lsp based) show definition
    noremenu PopUp.Show\ &information <cmd>lua vim.lsp.buf.hover()<cr>
    " add (lsp based) find references
    noremenu PopUp.Find\ &references <cmd>lua vim.lsp.buf.references()<cr>
    " add (treesitter+lsp based) peek function
    noremenu PopUp.&Peek\ function\ definition <cmd>lua require('nvim-treesitter.textobjects.lsp_interop').peek_definition_code('@function.outer')<cr>
    " add (treesitter+lsp based) peek class
    noremenu PopUp.Peek\ class\ definition <cmd>lua require('nvim-treesitter.textobjects.lsp_interop').peek_definition_code('@class.outer')<cr>
  elseif PopUpMenuExists("Show information")
    " remove the menus
    unmenu PopUp.Show\ &information
    unmenu PopUp.Find\ &references
    unmenu PopUp.&Peek\ function\ definition
    unmenu PopUp.Peek\ class\ definition
endif
endfunction

function! DebugMenuEnable()
  noremenu PopUp.Set\ breakpoint :Break
  noremenu PopUp.Clear\ breakpoint :Clear
  noremenu PopUp.Evaluate :Evaluate
  noremenu PopUp.-2- <Nop>
endfunction

function! DebugMenuDisable()
  if PopUpMenuExists("Set breakpoint")
    unmenu PopUp.Set\ breakpoint
    unmenu PopUp.Clear\ breakpoint
    unmenu PopUp.Evaluate
    unmenu PopUp.-2-
endif
endfunction

augroup debug_menu
  autocmd!
  autocmd User TermdebugStartPre call DebugMenuEnable()
  autocmd User TermdebugStopPost call DebugMenuDisable()
augroup END

augroup lsp
  autocmd!
  " set/unset tagfunc to lsp
  autocmd LspAttach * set tagfunc=v:lua.vim.lsp.tagfunc
  autocmd LspDetach * set tagfunc=
  " add lsp menu items
  autocmd BufEnter,LspAttach,LspDetach * call LspMenu()
augroup END

"redefinition of command in vimrc
command! -bang CoworkerMode call NvimCoworkerMode(<bang>1)

function! NvimCoworkerMode(enable)
  " defined in vimrc
  call CoworkerMode(a:enable)
  " augroup nvim_coworker_mode
  "   autocmd!
  "   if a:enable
  "     autocmd CursorHold * lua vim.lsp.buf.hover()
  "   endif
  " augroup END
endfunction

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
    pylsp = {},
    solargraph = {},
    cmake = {},
  }

  -- debugger stuff
  local dap = require('dap')
  dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = vim.g.cppdbg_command,
    options = {
      detached = false
    },
  }
  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'cppdbg',
      request = 'launch',
      program = function()
        if vim.g.cppdbg_program_exe then
          return vim.g.cppdbg_program_exe
        else
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      MIMode = 'lldb',
    },
  }
  vim.g.dap_configs = dap.configurations

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
    nmap('gd', vim.lsp.buf.definition)
    nmap('gd', vim.lsp.buf.definition)
    nmap('gd', vim.lsp.buf.definition)
    nmap('gd', vim.lsp.buf.definition)
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
    ensure_installed = {
      "c",
      "cpp",
      "elixir",
      "haskell",
      "javascript",
      "lua",
      "python",
      "regex",
      "ruby",
      "rust",
      "tsx",
      "typescript",
    },
    highlight = { enable = true },
    indent = {
       enable = true,
       disable = { "c", "cpp" }
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
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
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]["] = "@function.outer",
          ["]m"] = "@class.outer",
        },
        goto_next_end = {
          ["]]"] = "@function.outer",
          ["]M"] = "@class.outer",
        },
        goto_previous_start = {
          ["[["] = "@function.outer",
          ["[m"] = "@class.outer",
        },
        goto_previous_end = {
          ["[]"] = "@function.outer",
          ["[M"] = "@class.outer",
        }
      },
      lsp_interop = {
        enable = true,
        peek_definition_code = {
          ["<leader>pf"] = "@function.outer",
          ["<leader>pc"] = "@class.outer",
          ["<leader>ps"] = "@statement.outer",
          ["<leader>pp"] = "@paramater.outer"
        }
      }
    }
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
    extensions = {
      live_grep_args = {
        auto_quoting = true
      }
    }
  })
  telescope.load_extension('fzf')
  telescope.load_extension('ultisnips')
  telescope.load_extension('hoogle')
  telescope.load_extension('harpoon')

EOF
