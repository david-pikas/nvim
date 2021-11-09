" LSP
Plug 'neovim/nvim-lspconfig'
" tree sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" firefox integration
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
