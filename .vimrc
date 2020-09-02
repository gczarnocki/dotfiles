set encoding=utf-8

" Indentation
set autoindent              " New line inherits the indentation of previous lines
set expandtab               " Convert tabs to spaces
filetype indent plugin on   " Enable indentation rules that are file-type specific
set smarttab                " Insert 'tabstop' number of spaces when 'tab' is pressed
set tabstop=4               " Indent using 4 spaces

" Search
set hlsearch   " Search highlighting
set ignorecase " Ignore case when searching
set smartcase  " Switch search to case-sensitive if uppercase letter is used

" Rendering / UI
set cursorline     " Highlight current line
set number
syntax enable
set relativenumber
set noerrorbells
set visualbell

" Misc
set backspace=indent,eol,start
