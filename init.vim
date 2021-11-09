set runtimepath^=~/.vim runtimepath+=~/.vim/after
set runtimepath+=~/.local/share/nvim/site/autoload
let &packpath = &runtimepath
source ~/.vim/vimrc
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
    texlab = {},
    erlangls = {},
    eslint = {},
  }

  local custom_attach = function(client, bufnr_)
    bufnr = 0
    local function map(mode, key, value)
      vim.api.nvim_buf_set_keymap(bufnr,mode,key,value,{noremap = true, silent = true});
    end
    local function nmap(key, value) map('n', key, value) end
    local function set_option(opt, val)
      vim.api.nvim_buf_set_option(bufnr_, opt, val)
    end
    set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    nmap('gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    nmap('gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    nmap('gr', '<cmd>lua vim.lsp.buf.references()<CR>')
    nmap('gR', '<cmd>lua vim.lsp.buf.rename()<CR>')
    map('v', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    nmap('K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    nmap('ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    nmap('=f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
    nmap('].', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
    nmap('[.', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
    nmap('<leader>i', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
    nmap('<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  end

  for lang,opts in pairs(langs) do
    nvim_lsp[lang].setup(opts)
    nvim_lsp[lang].setup { on_attach = custom_attach }
  end

  -- tree sitter stuff
  require'nvim-treesitter.configs'.setup {
    ensure_installed = { "lua", "python", "javascript", "elixir",
                         "cpp", "typescript", "regex", "rust" },
    highlight = { enable = true },
    indent =  { enable = true },
  }
EOF
