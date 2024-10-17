" nvim plugin file: ~/.config/nvim/nvim-plugins.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
set runtimepath+=~/.local/share/nvim/site/autoload
set runtimepath-=C:/Program\ Files\ (x86)/nvim/share/nvim
let &packpath = &runtimepath
source ~/.vim/vimrc
" better startup times
lua vim.loader.enable()
" keep nvim from hanging on C-z on windows
if has('win32') || has('win64')
  nmap <C-z> <Nop>
endif
" neovide
if exists('g:neovide')
  set guifont=Fira\ Code:h8
  if !exists('g:neovide_transparency')
    let g:neovide_transparency=0.8
  endif
endif
let g:UltiSnipsSnippetDirectories = ["~/.vim/UltiSnips/"]

" firenvim
let g:firenvim_config = { 'localSettings': {'.*': {'takeover': 'never'}} }
if exists('g:started_by_firenvim')
  colorscheme shine
  " Can't remap <C-w> in firefox so we use <C-q> instead
  nmap <C-q> <C-w>
endif

" highlight yanked text
autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=200 }

nnoremap <leader>p<C-O> :TSTextobjectPeekDefinitionCode @

nnoremap [<C-O> :TSTextobjectGotoPreviousStart @
vnoremap [<C-O> :TSTextobjectGotoPreviousStart @

nnoremap ]<C-O> :TSTextobjectGotoNextEnd @
vnoremap ]<C-O> :TSTextobjectGotoNextEnd @

onoremap i<C-O> :TSTextobjectSelect @
vnoremap i<C-O> <Esc>:TSTextobjectSelect @

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
  if luaeval('0 < #vim.lsp.get_active_clients({ bufnr = 0 })')
    " add (lsp based) show definition
    noremenu PopUp.Show\ &information <cmd>lua vim.lsp.buf.hover()<cr>
    " add (lsp based) find references
    noremenu PopUp.Find\ &references <cmd>lua vim.lsp.buf.references()<cr>
    " add (treesitter+lsp based) peek function
    noremenu PopUp.&Peek\ function\ definition <cmd>lua require('nvim-treesitter.textobjects.lsp_interop').peek_definition_code('@function.outer')<cr>
    " add (treesitter+lsp based) peek class
    noremenu PopUp.Peek\ class\ definition <cmd>lua require('nvim-treesitter.textobjects.lsp_interop').peek_definition_code('@class.outer')<cr>
  elseif PopUpMenuExists("Show information") && 
        \ luaeval('"" == vim.api.nvim_win_get_config(0).relative')
    " remove the lsp menus, unless we're in a floating window
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
  " autocmd LspAttach * set tagfunc=v:lua.vim.lsp.tagfunc
  " autocmd LspDetach * set tagfunc=
  " add lsp menu items
  autocmd BufEnter,LspAttach,LspDetach * call LspMenu()
augroup END

" redefinition of command in vimrc
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

command! -range -nargs=1 -complete=command VEx call MarkSplitEx('<','>','<args>')

function! MarkSplitEx(mark1, mark2, command)
  let mark_ns = nvim_create_namespace('mark-split-ex')
  " note that getpos returns 1-indexed lines
  " but set_extmark takes 0-indexed lines
  let [_, l1, c1, _] = getpos("'".a:mark1)
  let emark1 = nvim_buf_set_extmark(0, mark_ns, l1-1, c1, {})
  let [_, l2, c2, _] = getpos("'".a:mark2)
  let emark2 = nvim_buf_set_extmark(0, mark_ns, l2-1, c2, {})
  call ExtmarkSplitEx(mark_ns, emark1, emark2, a:command)
endfunction

function! ExtmarkSplitEx(ns, emark1, emark2, command)
  let [el1, ec1] = nvim_buf_get_extmark_by_id(0, a:ns, a:emark1, {})
  let [el2, ec2] = nvim_buf_get_extmark_by_id(0, a:ns, a:emark2, {})
  let split1 = ec1 > match(getline(el1+1),'\S')
  let split2 = ec2 < strwidth(getline(el2+1))
  " we need paste so that the newline isn't auto-indented
  let oldpaste = &paste
  set paste
  " note that get_extmark returns 0-indexed
  " lines but setpos takes 1-indexed lines
  if split2 
    call setpos('.', [0,el2+1,ec2])
    normal a
  endif
  if split1
    call setpos('.', [0,el1+1,ec1])
    normal a
  endif
  let &paste=oldpaste
  execute (el1+1+split1).",".(el2+1+split1).a:command
  let [el1, ec1] = nvim_buf_get_extmark_by_id(0, a:ns, a:emark1, {})
  let [el2, ec2] = nvim_buf_get_extmark_by_id(0, a:ns, a:emark2, {})
  " if both marks have the same position, the content between them has
  " been deleted
  if el1 != el2 || ec2 != ec1
    if split1
      call setpos('.', [0,el1,ec1])
      norm gJ
    endif
    if split2
      call setpos('.', [0,el2-1,ec2])
      norm gJ
    endif
  endif
endfunction

source ~/.config/nvim/luainit.lua
