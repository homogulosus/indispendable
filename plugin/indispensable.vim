" =======================
" indispensable.vim
" Maintainer: homogulosus
" Version: 0.1
" =======================

if exists('g:loaded_indispensable') || &compatible
    finish
else
    let g:loaded_indispensable = 'yes'
endif

if has('autocmd')
    filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
    syntax enable
endif

filetype plugin on

set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab
set number
set relativenumber
set hidden
set nocursorline
set mouse=a
set termguicolors
set splitbelow
set noshowmode
set fillchars+=vert:.

set nrformats-=octal

if !has('nvim') && $ttimeoutlen == -100
    set ttimeout
    set ttimeoutlen=100
endif

set incsearch
set laststatus=2
set ruler
set wildmenu
set winbl=10 "Set floating window slightly transparent"

if !&scrolloff
  set scrolloff=2
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

set encoding=utf-8

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

set formatoptions+=j " Delete comment character when joining commented lines

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

set shell=/usr/bin/env\ zsh

set autoread

if &history < 1000
    set history=1000
endif
if &tabpagemax < 50
    set tabpagemax=50
endif
if !empty(&viminfo)
    set viminfo^=!
endif
set sessionoptions-=options
set viewoptions-=options

if &updatetime > 100
    set updatetime=100
endif

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

if empty(mapcheck('<C-U>', 'i'))
  inoremap <C-U> <C-G>u<C-U>
endif
if empty(mapcheck('<C-W>', 'i'))
  inoremap <C-W> <C-G>u<C-W>
endif

" Set backups
if has('persistent_undo')
    set undofile
    set undolevels=3000
    set undoreload=10000
endif

set backupdir=~/.local/share/nvim/backup " Don't put backups in current dir
set nobackup
set swapfile
set nowritebackup

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set spellsuggest=7
set linebreak
set shortmess=atI
set tw=80

set ignorecase
set smartcase
autocmd BufRead,BufNewFile *.md setlocal spell " Enable spellcheck for markdown files

" Folding
set foldmethod=syntax
set foldcolumn=1
set foldlevel=99
set cmdheight=2

set keywordprg=:Man " Open man pages in vim

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.md,*.html,*.css,*.scss,*.js,*.py,*.wiki,*.sh,*.zsh :call CleanExtraSpaces()
endif

" Add custom highlights in method that is executed every time a colorscheme is sourced
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f for details
function! TrailingSpaceHighlights() abort
    " Hightlight trailing whitespace
    highlight Trail ctermbg=red guibg=red
    call matchadd('Trail', '\s\+$', 100)
endfunction

autocmd! ColorScheme * call TrailingSpaceHighlights()

" Call method on window enter
augroup WindowManagement
    autocmd!
    autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of preview window when open
function! Handle_Win_Enter()
    if &previewwindow
        setlocal winhighlight=Normal:MarkdownError
    endif
endfunction

" Terminal more appealing
au TermOpen * setlocal nonumber norelativenumber
nmap <leader>T :sp +te<CR>
" wind resizing
augroup myterm | au!
    au TermOpen * if &buftype ==# 'terminal' | resize 10 | :startinsert | endif
augroup end

" Open in VScode
command! Code exe "silent !code '" . getcwd() . "' --goto '" . expand("%") . ":" . line(".") . ":" . col(".") . "'" | redraw!

" Diff Original File
command! DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_
        \ | diffthis | wincmd p | diffthis

" ====== REDIR ======= "
function! Redir(cmd, rng, start, end)
	for win in range(1, winnr('$'))
		if getwinvar(win, 'scratch')
			execute win . 'windo close'
		endif
	endfor
	if a:cmd =~ '^!'
		let cmd = a:cmd =~' %'
			\ ? matchstr(substitute(a:cmd, ' %', ' ' . expand('%:p'), ''), '^!\zs.*')
			\ : matchstr(a:cmd, '^!\zs.*')
		if a:rng == 0
			let output = systemlist(cmd)
		else
			let joined_lines = join(getline(a:start, a:end), '\n')
			let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
			let output = systemlist(cmd . " <<< $" . cleaned_lines)
		endif
	else
		redir => output
		execute a:cmd
		redir END
		let output = split(output, "\n")
	endif
	vnew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
endfunction

command! -nargs=1 -complete=command -bar -range Redir silent call Redir(<q-args>, <range>, <line1>, <line2>)

" vim:set ft=vim et sw=2:
