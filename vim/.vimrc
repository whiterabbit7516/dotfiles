" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Using a non-master branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
nnoremap <C-P> :Files<CR>

Plug 'itchyny/lightline.vim'

" Initialize plugin system
call plug#end()

nmap U <C-r>

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

nnoremap Y y$
nnoremap , @@
nnoremap > xp
nnoremap < hxph

set number