" LSP
Plug 'neovim/nvim-lspconfig'
" tree sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" viewing tree sitter information
Plug 'nvim-treesitter/playground'
" firefox integration
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" fuzzy moving around
Plug 'nvim-telescope/telescope.nvim'
nnoremap  <leader>ff <cmd>Telescope find_files<cr>
nnoremap  <leader>fh <cmd>Telescope help_tags<cr>
nnoremap  <leader><C-F> yiw<cmd>Telescope live_grep<cr><C-R>"
nnoremap  <leader>fb <cmd>Telescope buffers<cr>
nnoremap  <leader>ft <cmd>Telescope treesitter<cr>
nnoremap  <leader>fT <cmd>Telescope tags<cr>
nnoremap  <leader>f<C-T> <cmd>Telescope tagstack<cr>
nnoremap  <leader>fp <cmd>Telescope registers<cr>
nnoremap  <leader>fr <cmd>Telescope lsp_references<cr>
nnoremap  <leader>fs <cmd>Telescope lsp_document_symbols<cr>
nnoremap  <leader>fS <cmd>Telescope lsp_workspace_symbols<cr>
nnoremap  <leader>gd <cmd>Telescope lsp_definitions<cr>
nnoremap  <leader>f. <cmd>Telescope diagnostics<cr>
nnoremap  <leader>fq <cmd>Telescope quickfix<cr>
nnoremap  <leader>fo <cmd>Telescope jumplist<cr>
nnoremap  <leader>hf <cmd>Telescope harpoon marks<cr>
nnoremap  <leader>:  <cmd>Telescope commands<cr>
nnoremap  <leader>f: <cmd>Telescope command_history<cr>
" for passing comand line options to ripgrep
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
" missing Telescope subcommand
nnoremap  <leader>fg <cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>
" lua library
Plug 'nvim-lua/plenary.nvim'
" c-based fzf for ~20 times faster fuzzing
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
" ultisnipps integration
Plug 'fhill2/telescope-ultisnips.nvim'
" hoogle integration
Plug 'luc-tielen/telescope_hoogle'
" harpoon (file quick menu)
Plug 'ThePrimeagen/harpoon'
nnoremap <leader>m <cmd>lua require("harpoon.mark").add_file()<cr>
nnoremap <leader>hr <cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>
for i in range(1,9)
  execute "nnoremap '".i.' <cmd>lua require("harpoon.ui").nav_file('.i.')<cr>'
endfor
nnoremap <leader>hr <cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>
" nnoremap <expr> <tab> '<cmd>lua require("harpoon.ui").nav_file('.v:count1.')<cr>'
" treesitter-based text objects
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
" debugger pluggin
Plug 'mfussenegger/nvim-dap'
function! Lua_methodify(arg_string) 
  let args = a:arg_string->split(' ')
  let name = args[0]
  let params = args[1:]
  return ".".name.'('.a:000->join(', ').')'
endfunction
command! -nargs=+ Dap execute "lua require('dap')".Lua_methodify("<args>")
nnoremap <silent> <M-d>c <cmd>lua require'dap'.continue()<cr>
nnoremap <silent> <M-d>n <cmd>lua require'dap'.step_over()<cr>
nnoremap <silent> <M-d>i <cmd>lua require'dap'.step_into()<cr>
nnoremap <silent> <M-d>o <cmd>lua require'dap'.step_out()<cr>
nnoremap <silent> <M-d>b <cmd>lua require'dap'.toggle_breakpoint()<cr>
nnoremap <silent> <M-d>B <cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>
nnoremap <silent> <M-d>q <cmd>lua require'dap'.list_breakpoints(vim.fn.input('Breakpoint condition: '))<cr>
nnoremap <silent> <M-d>r <cmd>lua require'dap'.repl.open()<cr>
" refactoring
Plug 'ThePrimeagen/refactoring.nvim'
" Plug 'ThePrimeagen/refactoring.nvim', { 'on': 'Refactor' }
" augroup refactor_loaded
"   autocmd!
"   autocmd! User refactoring.nvim lua require('refactoring').setup({})
" augroup END
" dependency for preview actions
Plug 'aznhe21/actions-preview.nvim'
nnoremap <leader>fd <cmd>lua require('actions-preview').code_actions()<cr>
