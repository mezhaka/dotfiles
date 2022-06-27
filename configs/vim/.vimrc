call pathogen#infect()
call pathogen#helptags()

filetype plugin on 

"set nocompatible
set encoding=utf-8
syntax on

map ё `
map й q
map ц w
map у e
map к r
map е t
map н y
map г u
map ш i
map щ o
map з p
map х [
map ъ ]

map ф a
map ы s
map в d
map а f
map п g
map р h
map о j
map л k
map д l
map ж ;
map э '

map я z
map ч x
map с c
map м v
map и b
map т n
map ь m
map б ,
map ю .

map Ё ~
map Й Q
map Ц W
map У E
map К R
map Е T
map Н Y
map Г U
map Ш I
map Щ O
map З P
map Х {
map Ъ }

map Ф A
map Ы S
map В D
map А F
map П G
map Р H
map О J
map Л K
map Д L
map Ж :
map Э "

map Я Z
map Ч X
map С C
map М V
map И B
map Т N
map Ь M
map Б <
map Ю >

"set keymap=russian-jcukenwin
"set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

set scrolloff=3
set showcmd
"set wildmode=list:longest
set wildmode=longest,list,full
set wildmenu

set ttyfast
set laststatus=2
set relativenumber
set undofile
let mapleader = ","

set wrap

" wrapping whole words
"set linebreak

" Set to 100 instead of the default 80, cause my employer prefers wider lines.
set textwidth=100
set colorcolumn=89,101

"See :help fo-table for a table of options.
"The `t` is to auto-wrap text using textwidth and I do not want it to be automatic.
"The `q` is to format comments with gq.
"The `r` is to automatically insert the current comment leader after hitting <Enter>.
set formatoptions-=t
set formatoptions=qr


""Wrap at this column

"Make backspaces delete sensibly
set backspace=indent,eol,start

set tabstop=4
"Indentation levels every four columns
set expandtab
"Convert all tabs typed to spaces
set shiftwidth=4
"Indent/outdent by four columns
"set shiftround
"Indent/outdent to nearest tabstop


set matchpairs+=<:>
"Allow % to bounce between angles too
"Inserting these abbreviations inserts the corresponding Perl statement...

"<python shortcuts>
iab #!p #!/usr/bin/env python2.6
iab pymain if __name__ == "__main__":
"</python shortcuts>

"<bash insert shortcuts>
iab #!b #!/bin/bash<CR>set -u<CR>set -e<CR>#set -x
"</bash insert shortcuts>

set autowrite

"set mouse=a

set ignorecase smartcase
set hlsearch
set incsearch

set foldcolumn=3

nnoremap / /\v
vnoremap / /\v

" gdefault applies substitutions globally on lines. For example, instead of :%s/foo/bar/g you just type :%s/foo/bar/.
set gdefault
set showmatch


" Turn off highlighted stuff.
nnoremap <leader><space> :noh<cr>


" This setting was ruining the Ctrl-i (C-i) navigation shortcut, the opposite
" of Ctrl-o (C-o)
"nnoremap <tab> %

" Insert an empty line
nnoremap <leader>n kA<cr><Esc>


"save views automatically
"autocmd BufWinLeave * mkview
"autocmd BufWinEnter * silent loadview

syntax enable
set background=light
"let g:solarized_termcolors=256
"colorscheme solarized

"colorscheme desert
"colorscheme fruidle
"colorscheme proton
"colorscheme morning
colorscheme mezhaka


" Highlight cursor line
set cursorline


"highlight Comment ctermfg=lightblue guifg=lightblue


" Turn on 256 colors support
set t_Co=256

map <F4> :TlistToggle<cr>
let Tlist_Sort_Type='name'
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
set updatetime=450


" Create tags file, probably this can be set up depending on the type of file
" currently edited
"map <F8> : !ctags -R --C++-kinds=+pl --fields=+iaS --extra=+q .<cr>


" This grep thing below is a workaround for some bug in dscanner -- it
" produces two lines of garbage quite often
map <F8> : !dscanner --ctags src/ submodules/ \| grep -v '^{ return new void\[n];$' \| grep -v '^})$' > tags <cr>
" Versions of dscanner that worked well for me
" $dscanner --version
" v0.3.0-alpha d78ece6cbd4ed060acea33ed9a778e7d99d3b933
" v0.4.0-alpha 5c5a7572ea474a5969a6b6f6236ea82a64bad844

map <F3> :set hls!<cr>
map <F2> :clo<cr>
set ruler
set hidden

command! -nargs=* Wrap set wrap linebreak nolist


" If you want to move the cursor up and down by display lines instead, you can
" use the commands gk and gj instead.  Hitting two keys in quick succession
" feels slow compared to pressing a single key whilst holding down a modifier
" key. I have the following in my .vimrc file:
"
"vmap <C-j> gj
"vmap <C-k> gk
"vmap <C-4> g$
"vmap <C-6> g^
"vmap <C-0> g^
"nmap <C-j> gj
"nmap <C-k> gk
"nmap <C-4> g$
"nmap <C-6> g^
"nmap <C-0> g^


" Source the vimrc file after saving it
"if has("autocmd")
"  autocmd bufwritepost .vimrc source $MYVIMRC
"endif

noremap ; :

au FocusLost * :wa

" reselect the text that was just pasted
nnoremap <leader>v V`]

" show opened buffers
nnoremap <leader>l :ls<cr>

inoremap jj <ESC>

nnoremap <leader>w <C-w>s
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
runtime! ftplugin/man.vim


" I never use F1 as a help invocation, so:
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Show invisible symbols, like tabs and etc.
"set list
"set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
"set listchars=tab:▸\ ,eol:¬

" Options for gvim
set guifont=Consolas:h10

" Toggle of mouse=a, mouse= is mapped to F12 in toggle_mouse plugin


" Automatic indenting in C-like languages.
" I have turned it off because it ruins the formatting command gq in text
" files. For example, when it splits a line which has an opening brace on it
" the next line would be indented. At the same time this setting can be (and
" is ) turned on the basis of file type.
"set cindent shiftwidth=4


filetype indent on
set autoindent


" Copy current working directory to register.
" :r!pwd<cr> this pastes the pwd output, d$ deletes the output to register
" and "_ddk deletes a line into a black hole register and moves cursor one
" line up.
nnoremap <leader>p :r!pwd<cr>d$"_ddk


" This mapping can turn autoindent off, when I want to paste some text, but
" I use this seldom and will defenetely forget this mapping, so I leave it
" here commented out to look up the invpaste command here.
nnoremap <leader>i :set invpaste paste?<cr>
"nnoremap <F2> :set invpaste paste?<CR>
"set pastetoggle=<F2>
"set showmode


" Open quick fix window
nnoremap <leader>a :copen<cr>


" Open SVN diff window
" map <F9> :new<CR>:read !svn diff<CR>:set syntax=diff buftype=nofile<CR>gg

" Open git diff window
map <F9> :vnew<CR>:read !git diff --no-ext-diff <CR>:set syntax=diff buftype=nofile<CR>gg


" Turn on rainbow parenthesis https://github.com/luochen1990/rainbow.git
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
    \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
    \   'ctermfgs': ['darkblue', 'darkgreen', 'darkcyan', 'darkmagenta'],
    \   'operators': '_,_',
    \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \   'separately': {
    \       '*': {},
    \       'tex': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
    \       },
    \       'lisp': {
    \           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
    \       },
    \       'vim': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
    \       },
    \       'html': {
    \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
    \       },
    \       'css': 0,
    \   }
    \}


" Remove trailing whitespaces on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType sh,c,cpp,java,php,ruby,python,d autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()


" Highlight trailing whitespaces
match Todo /\s\+$/


" Jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif


" Set spell check
"set spell spelllang=en_us
" Set black foreground in terminal for misspelled words.
"hi SpellBad ctermfg=000


" Turn off\on wrap around for search
"set nowrapscan
set wrapscan


" Save session in .session.vim file and load it on startup
"fu! SaveSess()
    "execute 'mksession! ' . getcwd() . '/.session.vim'
"endfunction

"fu! RestoreSess()
"if filereadable(getcwd() . '/.session.vim')
    "execute 'so ' . getcwd() . '/.session.vim'
    "if bufexists(1)
        "for l in range(1, bufnr('$'))
            "if bufwinnr(l) == -1
                "exec 'sbuffer ' . l
            "endif
        "endfor
    "endif
"endif
"syntax on
"endfunction

"autocmd VimLeave * call SaveSess()
"autocmd VimEnter * call RestoreSess()


" Vertical split on startup
"au VimEnter * vsplit


" Map keys in command mode, so it is similar to bash' shortcuts
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>


" Toggle close matching braces and other pair symbols
nmap <Leader>x <Plug>ToggleAutoCloseMappings


" Put yanks in my Linux clipboard by default
set clipboard=unnamedplus


"When starting up, CtrlP sets its local working directory according to this
"variable: 

  "let g:ctrlp_working_path_mode = 'ra'

  "c - the directory of the current file.
  "a - like "c", but only applies when the current working directory outside of
      "CtrlP isn't a direct ancestor of the directory of the current file.
  "r - the nearest ancestor that contains one of these directories or files:
      ".git .hg .svn .bzr _darcs
  "w - begin finding a root from the current working directory outside of CtrlP
      "instead of from the directory of the current file (default). Only applies
      "when "r" is also present.
  "0 or <empty> - disable this feature.

"Note #1: if "a" or "c" is included with "r", use the behavior of "a" or "c" (as
"a fallback) when a root can't be found.

"Note #2: you can use a |b:var| to set this option on a per buffer basis
let g:ctrlp_working_path_mode = ''


" Spell check toggle
" TODO probably I should fix the problem with comments identification in D
" sources and then I won't need it anymore
nnoremap <leader>s :setlocal spell!<cr>


" I use it so rare that I don't need a map, but rather look up the command
" here.
" nnoremap <F5> :UndotreeToggle<cr>


" Turn on autocorrection plugin if I edit text file.
" Plugin address: https://github.com/panozzaj/vim-autocorrect.git
autocmd filetype text call AutoCorrect()


" The trailing space delimits the following symbol to type from :tag
nnoremap <leader>t :tag 


" Open tag in a vertical split
" map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
map <leader>d :vsp <CR>:exec("tag ".expand("<cword>"))<CR>


" Turn off automatic insersion of pair symbols (autoclose.vim) for text files
" this does not work: autocmd filetype text let g:autoclose_on = 0


" Turn off automatic indent for text
autocmd filetype text set noautoindent


" Turn off coloring that makd uses when building from command line
set makeprg=make\ COLOR=


" Force diff to open vertical splits
set diffopt+=vertical


" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>"


" This will look in the current directory for "tags", and work up the tree
" towards root until one is found. IOW, you can be anywhere in your source tree
" instead of just the root of it.
" set tags=./tags;/


" Map .. to go to a parrent directory while browsing git tree with figutive
autocmd User fugitive 
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif


" Show hidden files in file explorer
let NERDTreeShowHidden=1

