" ===================================
" Name: indispensable.vim
" Maintainer: homogulosus
" Version: 0.4
" Date: Tue Jul  7 15:30:00 EDT 2020
" ===================================

if exists('g:loaded_indispensable') || &compatible
  finish
else
  let g:loaded_indispensable = 'yes'
endif

" Make sure we are using an updated version of Vim
if v:version < 800
  echo "Upgrade your Vim! Indispensable.vim not loaded!"
  finish
endif

" nvim has both options enebled by default
if !has('nvim')
  if has('autocmd')
    filetype plugin indent on
  endif
  if has('syntax') && !exists('g:syntax_on')
    syntax enable
  endif
endif

filetype plugin on
silent! set number relativenumber hidden nocursorline termguicolors splitbelow noshowmode smartcase
silent! set mouse=a formatoptions+=j nrformats-=octal display+=lastline viewoptions-=options

if !has('nvim') && $ttimeoutlen == -100
  set ttimeout ttimeoutlen=100
endif

if has('winblend')
  set winbl=10 "Set floating window slightly transparent"
endif
if !&scrolloff
  set scrolloff=2
endif
if !&sidescrolloff
  set sidescrolloff=5
endif

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

if &history < 1000
  set history=1000
endif
if &tabpagemax < 50
  set tabpagemax=50 "nvim defaults
endif

if !has('nvim') && !empty(&viminfo)
  set viminfo^=!
endif

if &updatetime > 100
  set updatetime=100
endif

" Allow color schemes to do bright colors without forcing bold.
if !has('nvim')
  if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
  endif
endif

" CursorLineNr more visible
if !has('nvim')
  set cursorline
  set cursorlineopt=number
endif

highlight LineNR cterm=none ctermfg=Yellow ctermbg=none
highlight CursorLineNR cterm=bold ctermfg=Black ctermbg=none

if empty(mapcheck('<C-U>', 'i'))
  inoremap <C-U> <C-G>u<C-U>
endif
if empty(mapcheck('<C-W>', 'i'))
  inoremap <C-W> <C-G>u<C-W>
endif

" Set backups
if has('persistent_undo')
  set undofile undolevels=3000 undoreload=10000
endif

silent! set nobackup nowritebackup
silent! set spellsuggest=7 shortmess=atI

" Folding
silent! set foldmethod=syntax foldcolumn=1 foldlevel=99 cmdheight=2
silent! set keywordprg=:Man " Open man pages in vim

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if !has('nvim')
  if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
  else
    set signcolumn=yes
  endif
endif

" Delete trailing white space on save, useful for some filetypes ;)
function! CleanExtraSpaces() abort
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfun

augroup indispensable
	autocmd!
augroup END

if has("autocmd")
    autocmd indispensable BufWritePre *.txt,*.md,*.html,*.css,*.scss,*.js,*.py,*.wiki,*.sh,*.zsh :call CleanExtraSpaces()
endif

autocmd indispensable BufRead,BufNewFile *.md setlocal spell " Enable spellcheck for markdown files

" Add custom highlights in method that is executed every time a colorscheme is sourced
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f for details
function! TrailingSpaceHighlights() abort
  " Hightlight trailing whitespace
  highlight Trail ctermbg=red guibg=red
  call matchadd('Trail', '\s\+$', 100)
endfunction

autocmd indispensable ColorScheme * call TrailingSpaceHighlights()

" Call method on window enter
autocmd indispensable WinEnter * call Handle_Win_Enter()

" Change highlight group of preview window when open
function! Handle_Win_Enter() abort
  if &previewwindow
    setlocal winhighlight=Normal:MarkdownError
  endif
endfunction

" Add zsh to runtimepath if present
if executable('zsh')
  set shell=/usr/bin/env\ zsh
endif

" Open in VScode
if executable('code')
  command! Code exe "silent !code '" . getcwd() . "' --goto '" . expand("%") . ":" . line(".") . ":" . col(".") . "'" | redraw!
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
