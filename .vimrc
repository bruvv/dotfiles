syntax on                       " enable syntax highlighting
filetype plugin indent on       " enable filetype detection and settings

set cursorline                  " highlight the current line
set nobackup                    " use version control instead of backup files
set autoread                    " watch for file changes
set number                      " show line numbers
set showcmd                     " show selection metadata
set showmode                    " show INSERT, VISUAL, etc. mode
set showmatch                   " show matching brackets
set scrolloff=5                 " keep five lines visible above and below

" column-width visual indication
let &colorcolumn=join(range(81,999),",")
highlight ColorColumn ctermbg=235 guibg=#001D2F

" tabs and indenting
set autoindent smartindent smarttab
set expandtab                   " spaces instead of tabs
set tabstop=2 shiftwidth=2      " use two spaces for indentation

" bells
set noerrorbells visualbell

" search
set hlsearch                    " highlight search results

" clipboard
set clipboard=unnamed           " use the macOS clipboard

" shortcuts
nnoremap <silent> <F2> :Lexplore<CR>

" remapped keys
inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}
