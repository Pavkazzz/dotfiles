syntax on

set nocompatible              " be iMproved, required
filetype off                  " required
let g:solarized_termcolors=256

execute pathogen#infect()

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'



"------------------=== Other ===----------------------
Plugin 'bling/vim-airline'   	    	" Lean & mean status/tabline for vim
Plugin 'fisadev/FixedTaskList.vim'  	" Pending tasks list
Plugin 'rosenfeld/conque-term'      	" Consoles as buffers
Plugin 'tpope/vim-surround'	   	" Parentheses, brackets, quotes, XML tags, and more

"--------------=== Snippets support ===---------------
Plugin 'garbas/vim-snipmate'		" Snippets manager
Plugin 'MarcWeber/vim-addon-mw-utils'	" dependencies #1
Plugin 'tomtom/tlib_vim'		" dependencies #2
Plugin 'honza/vim-snippets'		" snippets repo

"---------------=== Languages support ===-------------
" --- Python ---
Plugin 'klen/python-mode'	        " Python mode (docs, refactor, lints, highlighting, run and ipdb and more)
Plugin 'davidhalter/jedi-vim' 		" Jedi-vim autocomplete plugin
Plugin 'mitsuhiko/vim-jinja'		" Jinja support for vim
Plugin 'mitsuhiko/vim-python-combined'  " Combined Python 2/3 for Vim


call vundle#end()            		" required
filetype on
filetype plugin on
filetype plugin indent on


syntax enable
set background=dark
colorscheme solarized 

"=====================================================
" General settings
"=====================================================
set backspace=indent,eol,start
aunmenu Help.

set guifont=Source\ Code\ Pro:h12

let no_buffers_menu=1
set mousemodel=popup

set ruler
set completeopt-=preview
set gcr=a:blinkon0
if has("gui_running")
  set cursorline
endif

set ttyfast

" включить подсветку кода
syntax on

ball
set switchbuf=useopen

set visualbell t_vb= 
set novisualbell       


set enc=utf-8     " utf-8 по дефолту в файлах
set ls=2             " всегда показываем статусбар
set incsearch     " инкреминтируемый поиск
set hlsearch     " Ð	¿одсветка результатов поиска
set nu          	   " показывать номера строк
set scrolloff=5     	" 5 строк при скролле за раз


set nobackup 	     " no backup files
set nowritebackup    " only in case you don't want a backup file while editing
set noswapfile 	     " no swap files

augroup vimrc_autocmds
    autocmd!
    autocmd FileType python set colorcolumn=140
    autocmd FileType ruby,python,javascript,c,cpp highlight Excess ctermbg=DarkGrey guibg=Black
    autocmd FileType ruby,python,javascript,c,cpp match Excess /\%140v.*/
augroup END

let g:snippets_dir = "~/.vim/vim-snippets/snippets"


set laststatus=2
let g:letirline_theme='powerlineish'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'


map <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 0 " автофокус на Tagbar при открытии


map <F3> :NERDTreeToggle<CR>
let NERDTreeIgnore=['\~$', '\.pyc$', '\.pyo$', '\.class$', 'pip-log\.txt$', '\.o$']  


map <F2> :TaskList<CR> 	   " отобразить список тасков на F2


map <C-q> :bd<CR> 	   " CTRL+Q - закрыть текущий буффер

"=====================================================
"" Python-mode settings
"=====================================================
"" отключаем автокомплит по коду (у нас вместо него используется jedi-vim)
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0

autocmd FileType python nnoremap <buffer> <F9> :exec '!python' shellescape(@%, 1)<cr>
autocmd FileType python set completeopt-=preview 
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8
			\ formatoptions+=croq softtabstop=4 smartindent
			\ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
autocmd FileType pyrex setlocal expandtab shiftwidth=4 tabstop=8 
			\ softtabstop=4 smartindent 
			\ cinwords=if,elif,else,for,while,try,except,finally,def,class,with


"документация
let g:pymode_doc = 0
let g:pymode_doc_key = 'K'
" проверка кода
let g:pymode_lint = 1
let g:pymode_lint_checker = "pyflakes,pep8"
let g:pymode_lint_ignore="E501,W601,C0110"
" провека кода после сохранения
let g:pymode_lint_write = 1


" поддержка virtualenv
let g:pymode_virtualenv = 1


let g:pymode_breakpoint = 1
let g:pymode_breakpoint_key = '<leader>b'


let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all


let g:pymode_folding = 0

let g:pymode_run = 0

let g:jedi#popup_select_first = 0


