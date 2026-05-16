" ============================================================
" Basics
" ============================================================
set encoding=utf-8
set visualbell
set backspace=indent,eol,start    " intuitive backspace
set updatetime=250

" ============================================================
" Syntax & colors
" ============================================================
syntax on
colorscheme elflord

" ============================================================
" Display
" ============================================================
set number
set cursorline
set cursorcolumn
set guifont=Fira_Code:h8

" Show whitespace
set list
set listchars=tab:»\ ,extends:›,precedes:‹,trail:•

" ============================================================
" Indentation
" ============================================================
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" ============================================================
" Text width / wrapping
" ============================================================
set textwidth=100

" ============================================================
" Search
" ============================================================
set hlsearch
set ignorecase
set smartcase

" ============================================================
" Editing behavior
" ============================================================
" Disable auto-comment-continuation on <Enter>/o/O.
" The autocmd is what actually sticks; ftplugins clobber the global.
set formatoptions-=o
autocmd FileType * setlocal formatoptions-=o

" ============================================================
" Folding
" Set up indent folding but start with everything unfolded.
" ============================================================
set foldmethod=indent
set nofoldenable

" ============================================================
" Keybindings
" Tab / Shift-Tab cycle through TABS (not buffers — use :bnext/:bprev for those)
" ============================================================
nnoremap <Tab>   :tabn<CR>
nnoremap <S-Tab> :tabp<CR>

" ============================================================
" Status line
" ============================================================
set laststatus=2
set statusline=%F%m%r%h%w
set statusline+=\ [FORMAT=%{&ff}]
set statusline+=\ [TYPE=%Y]
set statusline+=\ [ASCII=%03.3b:0x%02.2B]
set statusline+=\ [POS=%04l,%04v][%p%%]
set statusline+=\ [LEN=%L]