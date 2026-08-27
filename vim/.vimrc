"""""""""""""""""""""""""""""""" 
" keybindings
"""""""""""""""""""""""""""""""" 

nnoremap J 8j
nnoremap K 8k
nnoremap H 8h
nnoremap L 8l
nnoremap W 4w
nnoremap E 4e
nnoremap B 4b
nnoremap s i<space><esc>
nnoremap S a<space><esc>

vnoremap J 8j
vnoremap K 8k
vnoremap H 8h
vnoremap L 8l
vnoremap W 4w
vnoremap E 4e
vnoremap B 4b

nnoremap U <C-r>
nnoremap Y y$
nnoremap , @@
nnoremap Q @q
nnoremap > xp
nnoremap < hxph

"""""""""""""""""""""""""""""""" 
" lines
"""""""""""""""""""""""""""""""" 

set number          " show line numbers
set scrolloff=12    " keep 12 lines visible above/below cursor when scrolling

"""""""""""""""""""""""""""""""" 
" backups
"""""""""""""""""""""""""""""""" 

set nobackup        " don't keep a backup copy after overwriting a file
set nowritebackup   " don't create a temp backup copy while writing
set noswapfile       " don't create .swp crash-recovery files
set noundofile       " don't persist undo history to disk between sessions

"""""""""""""""""""""""""""""""" 
" search
"""""""""""""""""""""""""""""""" 

set hlsearch        " highlight all matches of the last search
set incsearch       " jump to matches as you type the search pattern

"""""""""""""""""""""""""""""""" 
" tabs
"""""""""""""""""""""""""""""""" 

set expandtab       " insert spaces instead of tab characters
set tabstop=2       " a tab character displays as 2 spaces
set autoindent      " match indentation of the previous line on a new line

"""""""""""""""""""""""""""""""" 
" autosave
"""""""""""""""""""""""""""""""" 

set autoread        " reload a file automatically if it changed on disk
set updatetime=2000 " trigger CursorHold after 2s of inactivity
autocmd CursorHold,CursorHoldI * silent! update  " autosave on idle (see above)

"""""""""""""""""""""""""""""""" 
" cursor style
"""""""""""""""""""""""""""""""" 

let &t_SI = "\e[4 q"
let &t_EI = "\e[2 q"
let &t_SR = "\e[4 q"
