" Name:     Lucas Javaudin's neovim configuration
" Author:   Lucas Javaudin <me@lucasjavaudin.com>
" License:  MIT license

" Read bépo's mapping
if filereadable(expand("~/.config/nvim/vimrc.bepo"))
    source $HOME/.config/nvim/vimrc.bepo
endif

if has('nvim')
    let s:plug_vim_path = '~/.config/nvim/autoload/plug.vim'
    let s:plugin_path = '~/.config/nvim/plugged'
    let g:vimtex_compiler_progname = 'nvr'
else
    let s:plug_vim_path = '~/.vim/autoload/plug.vim'
    let s:plugin_path = '~/.vim/plugged'
endif

" General {{{ "

" Environment - Encoding, Indent, Fold {{{ "

set nocompatible " be iMproved, required

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Configure backspace so it acts as it should act
set backspace=eol,start,indent

" With a map leader it's possible to do extra key combinations
let mapleader = ","
let maplocalleader = ";"

" Enable clipboard if possible
if has('clipboard')
    if has('unnamedplus') " When possible use + register for copy-paste
        set clipboard=unnamedplus
    else " On mac and Windows, use * register for copy-paste
        set clipboard=unnamed
    endif
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

set autoindent " Auto indent
set smartindent " Smart indent

" keep 5 lines when scrolling
set scrolloff=5

" raise a dialog when leaving with unsaved changes
set confirm

filetype on
filetype plugin on
filetype plugin indent on

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
set smarttab

set expandtab " Use spaces instead of tabs

set wrap " Wrap lines

" set iskeyword+=-
set whichwrap+=<,>,h,l,[,]

" clear vert split and empty lines fillchar
if has('nvim')
    set fillchars=vert:\ ,eob:\ ,
else
    set fillchars=vert:\ ,
endif

" Use these symbols for invisible chars
set listchars=tab:¦\ ,eol:¬,trail:⋅,extends:»,precedes:«

set foldlevel=100 " unfold all by default

" }}} Environment - Encoding, Indent, Fold "

" Appearence - Scrollbar, Highlight, Linenumber {{{ "

" Enable syntax highlighting
syntax enable

set shortmess=caoOtTI " Abbrev. of messages

" Highlight current line
set cursorline

" Always show current position
set ruler

" Show line number by default
set number relativenumber

" Turn spell check off
set nospell

" Height of the command bar
set cmdheight=2
" Turn on the Wild menu
set wildmenu
set wildmode=list:longest,full
" Ignore compiled files
set wildignore=*.so,*.swp,*.pyc,*.pyo,*.exe,*.7z
if has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*,*\desktop.ini
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" }}} Appearence - Scrollbar, Highlight, Linenumber "

" Edit - Navigation, History, Search {{{ "

set completeopt=menu,preview,longest
set pumheight=10

" Automatically close the preview window when popup menu is invisible
if !exists('g:rc_auto_close_pw')
    let g:rc_auto_close_pw = 1
else
    if g:rc_auto_close_pw == 0 | augroup! rc_close_pw | end
endif

augroup rc_close_pw
    autocmd!
    autocmd CursorMovedI,InsertLeave * call RCClosePWOrNot()
augroup END

function! RCClosePWOrNot()
    if g:rc_auto_close_pw
        if !pumvisible() && (!exists('*getcmdwintype') || empty(getcmdwintype()))
            silent! pclose
        endif
    endif
endfunction

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif

" Visually select the text that was last edited/pasted
nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'

" Set to auto read when a file is changed from the outside
set autoread

set updatetime=200

" Set how many lines of history VIM has to remember
set history=1000 " command line history

" Don't backup orignal files
set nobackup
set nowritebackup

" For regular expressions turn magic on
set magic

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Disable highlight when AltGr+9 is pressed
nnoremap <silent> ÷ :nohlsearch<CR>

" use skeletons
" autocmd BufNewFile *.py 0r ~/.config/nvim/templates/skeleton.py
" autocmd BufNewFile *.tex 0r ~/.config/nvim/templates/skeleton.tex

" close vim if the only window left is the quickfix
au BufEnter * call MyLastWindow()
function! MyLastWindow()
  if &buftype=="quickfix"
    if winbufnr(2) == -1
      quit
    endif
  endif
endfunction

" }}} Edit - Navigation, History, Search "

" Buffer - BufferSwitch, FileExplorer, StatusLine {{{ "

" A buffer becomes hidden when it is abandoned
set hidden

let g:netrw_liststyle = 3
let g:netrw_winsize = 30
" nnoremap <silent> <Leader>e :Vexplore <C-r>=expand("%:p:h")<CR><CR>
autocmd FileType netrw setlocal bufhidden=delete

" Specify the behavior when switching between buffers
set switchbuf=useopen
set showtabline=1

set splitright " Puts new vsplit windows to the right of the current
set splitbelow " Puts new split windows to the bottom of the current

" Always show status line
set laststatus=2
set statusline=%<%f\ " filename
set statusline+=%w%h%m%r " option
set statusline+=\ [%{&ff}]/%y " fileformat/filetype
set statusline+=\ [%{getcwd()}] " current dir
set statusline+=\ [%{&encoding}] " encoding
set statusline+=%=%-14.(%l/%L,%c%V%)\ %p%% " Right aligned file nav info

" }}} Buffer - BufferSwitch, FileExplorer, StatusLine "

" Key Mappings {{{ "

" Bash like keys for the command line
cnoremap <C-a> <Home>

" Ctrl-[hl]: Move left/right by word
cnoremap <C-h> <S-Left>
cnoremap <C-l> <S-Right>

" Ctrl-[bf]: I don't use <C-b> to open mini window often
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>

" Ctrl-a: Go to begin of line
inoremap <C-a> <Home>

" Ctrl-e: Go to end of line
inoremap <C-e> <End>

" Save buffer with S
nnoremap S :w<CR>

" keep , and ; function
noremap è ;
noremap È ,

" follow links
nnoremap <leader>, <C-]>

" better yank
nnoremap Y y$

" move to end of previous word easily
noremap E ge
noremap ge E

" search current Visual selection
xnoremap * :<C-U>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-U>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" repeat :substitute command with same flags
nnoremap & :&&<CR>
" repeat :substitute command to visual selection
xnoremap & :&&<CR>

" easily navigate the location list
" noremap à :lnext<CR>
" noremap À :lprevious<CR>
noremap <leader>à :ll<CR>

" localleader n to toggle numbers
nnoremap <localleader>n :setlocal number! relativenumber!<CR>
" localleader N to toggle relative numbers
nnoremap <localleader>N :setlocal relativenumber!<CR>

" shortcuts for spellcheck
nnoremap <leader>se :set spell spelllang=en_us<CR>
nnoremap <leader>sf :set spell spelllang=fr<CR>
nnoremap <leader>ss :set spell spelllang=es<CR>
nnoremap <leader>sq :set nospell<CR>
" navigate spelling mistakes
nnoremap <leader>sn ]s
nnoremap <leader>sp [s
" quick correct
nnoremap <leader>sc 1z=
" add to dictionary
nnoremap <leader>sa zg

" easily open and close folds
nnoremap <SPACE> za
" open all folds at cursor
nnoremap Ç zO
" close all folds at cursor
nnoremap ç :set foldlevel=0<CR>
" increase fold level
nnoremap » zr
" decrease fold level
nnoremap « zm

" break undo at each line break
inoremap <CR> <C-]><C-G>u<CR>

" <C-L> redraws screen and reset syntax
nnoremap <C-L> :syntax sync fromstart<CR><C-L>

" }}} Key Mappings "

" Misc {{{ "

" For when you forget to sudo... Really write the file.
if !has('win32')
    command! W w !sudo tee % > /dev/null
endif

augroup rc_warning_highlight
    autocmd!
    autocmd ColorScheme * call matchadd('Todo', '\W\zs\(NOTICE\|WARNING\|DANGER\)')
augroup END

augroup rc_ft_settings
    autocmd!
    autocmd BufNewFile,BufRead *.org setlocal filetype=org commentstring=#%s
    autocmd BufNewFile,BufRead *.tex setlocal filetype=tex
    autocmd FileType qf setlocal nowrap
augroup END

" Use <ESC> to exit terminal mode
tnoremap <Esc> <C-\><C-n>

" }}} Misc "

" }}} General "

" Plugins List & Config {{{ "

" Plugin List {{{ "
if filereadable(expand(s:plug_vim_path))
    call plug#begin(s:plugin_path)
        Plug 'kana/vim-textobj-user'
        Plug 'bps/vim-textobj-python', {'for': 'python'}
        if has('node')
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
        endif
        Plug 'ashfinal/vim-one'
        Plug 'bling/vim-airline'
        Plug 'SirVer/ultisnips'
        Plug 'honza/vim-snippets'
        Plug 'scrooloose/nerdcommenter'
        Plug 'lervag/vimtex'
        Plug 'tpope/vim-fugitive'
        Plug 'tpope/vim-repeat'
        Plug 'tpope/vim-surround'
        Plug 'godlygeek/tabular'
        Plug 'tommcdo/vim-exchange'
        Plug 'airblade/vim-gitgutter'
        Plug 'b4winckler/vim-angry'
        Plug 'lambdalisue/vim-manpager'
        Plug 'chrisbra/csv.vim'
        Plug 'rust-lang/rust.vim', {'for': 'rust'}
        Plug 'kshenoy/vim-signature'
        Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
        Plug 'averms/black-nvim', {'for': 'python'}
        Plug 'chaoren/vim-wordmotion'
        Plug 'kaarmu/typst.vim', {'branch': 'main'}
        Plug 'catgoose/nvim-colorizer.lua'
    call plug#end()
endif
" }}} Plugin List "

" Plugin Config {{{ "

" Plugin Config - coc.nvim {{{ "

if has('node')
    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gl <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
    nmap <silent> g= <Plug>(coc-format)
    vmap <silent> g= <Plug>(coc-format-selected)
    " Remap for rename current word
    nmap gm <Plug>(coc-rename)
    " Show documentation in preview window
    nmap <silent> gh :call CocAction('doHover')<CR>
    nmap <silent> gc :CocList diagnostics<CR>
    nmap <silent> go :CocList outline<CR>
    " nmap <silent> gs :CocList -I symbols<CR>

    " Use à and À to navigate diagnostics
    nmap <silent> à <Plug>(coc-diagnostic-next)
    nmap <silent> À <Plug>(coc-diagnostic-prev)
    nmap <silent> gà :CocDiagnostics<CR><C-W><C-P>

    set signcolumn=yes
endif

" }}} Plugin Config - coc.nvim "

" Plugin Config - onecolorscheme {{{ "

colorscheme one
set background=dark
set termguicolors

" }}} Plugin Config - onecolorscheme "

" Plugin Config - airline {{{ "

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" }}} Plugin Config - airline "

" Plugin Config - ultisnips {{{ "

let g:UltiSnipsExpandTrigger = "<Tab>"
let g:UltiSnipsJumpForwardTrigger = "<Tab>"
let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"
let g:UltiSnipsEditSplit = "context"

" }}} Plugin Config - ultisnips "

" Plugin Config - nerdcommenter {{{ "

" Always leave a space between the comment character and the comment
let NERDSpaceDelims = 1

" }}} Plugin Config - nerdcommenter "

" Plugin Config - vimtex {{{ "

let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-xelatex',
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}

" Disable mapping
let g:vimtex_mappings_enabled = 0
let g:vimtex_imaps_enabled = 0

" Enable folding
let g:vimtex_fold_enabled = 1

" Only open the quickfix window if there are errors
" let g:vimtex_quickfix_open_on_warning = 0

" Configure viewer
let g:vimtex_view_method = 'zathura'

" }}} Plugin Config - vimtex "

" Plugin Config - vim-surround {{{ "

" change mapping
let g:surround_no_mappings = 1
nmap ds <Plug>Dsurround
nmap ls  <Plug>Csurround
nmap lS  <Plug>CSurround
nmap ys  <Plug>Ysurround
nmap yS  <Plug>YSurround
nmap yss <Plug>Yssurround
nmap ySs <Plug>YSsurround
nmap ySS <Plug>YSsurround
xmap S   <Plug>VSurround
xmap gS  <Plug>VgSurround
if !exists("g:surround_no_insert_mappings") || ! g:surround_no_insert_mappings
 if !hasmapto("<Plug>Isurround","i") && "" == mapcheck("<C-S>","i")
  imap    <C-S> <Plug>Isurround
 endif
 imap      <C-G>s <Plug>Isurround
 imap      <C-G>S <Plug>ISurround
endif

" }}} Plugin Config - vim-surround "

" Plugin Config - vim-exchange {{{ "

" change mapping
nmap lx <Plug>(Exchange)
xmap X <Plug>(Exchange)
nmap lxc <Plug>(ExchangeClear)
nmap lxx <Plug>(ExchangeLine)

" }}} Plugin Config - vim-exchange "

" Plugin Config - vim-gitgutter {{{ "

" add some mappings
nmap <leader>hn <Plug>(GitGutterNextHunk)
nmap <leader>hp <Plug>(GitGutterPrevHunk)
nmap <leader>hq :GitGutterDisable<CR>

" turn on line number highlighting (for neovim)
let g:gitgutter_highlight_linenrs = 1

" }}} Plugin Config - vim-gitgutter "

" Plugin Config - vim-wordmotion {{{ "

" customize mappings
let g:wordmotion_mappings = {
\ 'w' : '<leader>é',
\ 'b' : '<leader>b',
\ 'e' : '<leader>e',
\ 'ge' : '<leader>E',
\ 'aw' : 'av',
\ 'iw' : 'iv'
\ }

" }}} Plugin Config - vim-wordmotion "

" }}} Plugins List & Config "
