" LSP
Plug 'neovim/nvim-lspconfig'
" tree sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" firefox integration
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" fuzzy moving around
Plug 'nvim-telescope/telescope.nvim'
nnoremap  <leader>ff <cmd>Telescope find_files<cr>
nnoremap  <leader>fg <cmd>Telescope live_grep<cr>
nnoremap  <leader><C-F> yiw<cmd>Telescope live_grep<cr><C-R>"
nnoremap  <leader>fb <cmd>Telescope buffers<cr>
nnoremap  <leader>ft <cmd>Telescope treesitter<cr>
nnoremap  <leader>fr <cmd>Telescope lsp_references<cr>
nnoremap  <leader>fs <cmd>Telescope lsp_document_symbols<cr>
nnoremap  <leader>fS <cmd>Telescope lsp_workspace_symbols<cr>
nnoremap  <leader>gd <cmd>Telescope lsp_definitions<cr>
nnoremap  <leader>f. <cmd>Telescope diagnostics<cr>
nnoremap  <leader>f: <cmd>Telescope command_history<cr>
nnoremap  <leader>fq <cmd>Telescope quickfix<cr>
nnoremap  <leader>fo <cmd>Telescope jumplist<cr>
" hoogle integration for tree sitter
Plug 'luc-tielen/telescope_hoogle'
" lua library
Plug 'nvim-lua/plenary.nvim'
