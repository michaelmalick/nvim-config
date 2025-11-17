"" Nvim config file


"" nvim base settings --------------------------------------
set ignorecase                 " Case insensitive search
set smartcase                  " Case sensitive when uppercase present
set wildignorecase             " Ignore case in mini-buffer completion
set noshowmode                 " Don't show mode in cmd line
set linebreak                  " Lines break at spaces
set foldlevel=10               " Open 10 fold levels on buffer entry
set path+=**                   " Search sub-directories too
set noerrorbells               " No beeping!
set spellcapcheck=''           " Turn off cap checking of first word of sentence
set fillchars=fold:\ ,vert:│   " Chars used to fill space
set previewheight=20           " Increase size of preview windows
set tabstop=4                  " Set tab space to 4
set shiftwidth=4               " Number of spaces to use for autoindenting
set softtabstop=4              " Let backspace delete indent
set expandtab                  " Tabs as spaces
set virtualedit=block          " Easier visual blocks
set fileformats=unix,dos,mac   " Use unix as standard file type
set noswapfile                 " Don't create swapfiles
set cursorline                 " Highlight current line
set clipboard+=unnamedplus     " Use system clipboard too
set undofile                   " Enable persistent undo
set textwidth=80               " Wrap text at column 80
set list lcs=trail:·,tab:»·    " Show invisibles
set winborder=single           " Floating window borders
exe 'set spellfile='.stdpath('config')."/spell/en.utf-8.add"



"" colors --------------------------------------------------
"" nvim autoloads colorschemes, don't need to use :packadd
set termguicolors
set background=dark
silent! colorscheme solarized-dark

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank {higroup = 'Visual', timeout = 300}
augroup END



"" statusline ----------------------------------------------
set laststatus=2                               " Always show status line
set statusline=                                " Initialize empty status line
set statusline+=\ %n\                          " Buffer number
set statusline+=\ %f\                          " File name
set statusline+=%m                             " Modified flag
set statusline+=%r                             " Read only flag
set statusline+=%h                             " Help flag
set statusline+=%w                             " Preview window flag
set statusline +=\ \ %{fugitive#statusline()}  " Git branch
set statusline+=%=                             " Switch to right side
set statusline +=\ %{&ff}\                     " File format
let &stl .= ' %{&fenc !=# "" ? &fenc : &enc} ' " File encoding
set statusline+=\ %3l:%-2c                     " Current line:column
set statusline+=\ \ %L                         " Total lines
set statusline+=\ \ %P\                        " Percentage of file showing



"" terminal ------------------------------------------------
tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
tnoremap <C-w>h <C-\><C-n><C-w>h
tnoremap <C-w>j <C-\><C-n><C-w>j
tnoremap <C-w>k <C-\><C-n><C-w>k
tnoremap <C-w>l <C-\><C-n><C-w>l
tnoremap <C-w>w <C-\><C-n><C-w>w
tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>

"" Toggle startinsert when entering a neovim terminal
function! s:toggle_terminal_startinsert() abort
    if !exists('#mjm_neoterminal#BufWinEnter')
        augroup mjm_neoterminal
            autocmd!
            au BufWinEnter,WinEnter term://* startinsert
            "" stop BufExplorer from opening buffers in insert
            au BufLeave term://* stopinsert
        augroup END
    else
        augroup mjm_neoterminal
            autocmd!
        augroup END
    endif
endfunc
call <SID>toggle_terminal_startinsert()
command! ToggleTerminalStartinsert call <SID>toggle_terminal_startinsert()
nnoremap <silent> yoa :ToggleTerminalStartinsert<CR>



"" abbreviations -------------------------------------------
iabbrev adn and
iabbrev recieve receive
iabbrev recieved received
iabbrev beleive believe
iabbrev occurence occurrence
iabbrev occured occurred
iabbrev occuring occurring
iabbrev Oncor Oncorhynchus
iabbrev seperate separate
iabbrev seperated separated



"" base mappings -------------------------------------------
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

let mapleader = ' '
let maplocalleader = '\'
nnoremap j gj
nnoremap k gk
nnoremap <BS> <C-^>
inoremap <silent> <C-]> <C-r>=repeat('-', 61-virtcol('.'))<CR>
nnoremap <silent> gh :nohlsearch<CR>

"" notes and files
nnoremap <silent> <leader>1 :edit ~/.notes.md<CR>
nnoremap <silent> <leader>9 :edit ~/Documents/research/<CR>

"" vimrc
let g:myvimrc = stdpath('config')."/init.vim"
nnoremap <silent> <leader>0 :execute 'edit' g:myvimrc<CR>

"" fold text object
xnoremap <silent> az :<C-U> normal! [zV]z<CR>
xnoremap <silent> iz :<C-U> normal! [zjV]zk<CR>
onoremap <silent> az :<C-U> normal! [zV]z<CR>
onoremap <silent> iz :<C-U> normal! [zjV]zk<CR>



"" folding -------------------------------------------------
function! MJM_fold_expr() abort
    if &ft == 'vim'
        let pattern = '^".*-\{4}$'
    endif
    if &ft == 'lua'
        let pattern = '^--.*-\{4}$'
    endif
    if &ft == 'r' || &ft == 'julia' || &ft == 'python'
        let pattern = '^#.*-\{4}$'
    endif
    let h1 = matchstr(getline(v:lnum), pattern)
    if empty(h1)
        return "="
    elseif !empty(h1)
        return ">1"
    endif
endfunc

augroup mjm_folding
    autocmd!
    au FileType vim,lua,r,julia,python setlocal foldmethod=expr
    au FileType vim,lua,r,julia,python setlocal foldexpr=MJM_fold_expr()
augroup END



"" grep ----------------------------------------------------
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

"" Search for input string, e.g., :Grep vim
command! -nargs=+ Grep  execute 'silent grep! <args>' | copen | execute '/<args>'
command! -nargs=+ Grepv execute 'noautocmd vimgrep! /<args>/j *' | copen | execute '/<args>'
command! Todo :Grepv \CTODO\|\CWAIT\|\CFIXME\|\CBUG

"" Search for word under cursor
command! Grepw  execute 'silent grep! ' . expand("<cword>") | copen
command! GrepW  execute 'silent grep! ' . expand("<cWORD>") | copen
nnoremap <silent> <leader>* :Grepw<CR>

"" Occur from emacs
command! -nargs=1 Occur execute 'noautocmd vimgrep! /<args>/j %' | copen | execute '/<args>'



"" quickfix ------------------------------------------------
augroup mjm_qf
    autocmd!
    au FileType qf setlocal nowrap
    au FileType qf setlocal cursorline
    au FileType qf nmap <silent><buffer> ! :cclose <bar> vert copen <bar> wincmd =<CR>
    au FileType qf nmap <silent><buffer> gq :hide<CR>
    "" needed if <return> is mapped in normal mode
    au BufReadPost quickfix nnoremap <CR> <CR>
augroup END



"" commands + functions ------------------------------------

"" :CD
function! s:lcd(bang) abort
    "" :CD! will try to find the git root dir and set the working directory
    "" there, if it can't find a .git dir in the parent dirs then the dir of the
    "" current file is used
    if a:bang
        let l:new_lcd = <SID>get_git_root()
        if l:new_lcd == ''
            let l:new_lcd = expand('%:p:h')
        endif
    else
        let l:new_lcd = expand('%:p:h')
    endif
    exe 'lcd' l:new_lcd
    echo 'Changed directory to: ' . l:new_lcd
endfunc
command! -bang CD call <SID>lcd(<bang>0)


"" git root finder
function! s:get_git_root() abort
  let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  return v:shell_error ? '' : root
endfunc


"" :SyntaxEcho
function! s:syntax_echo() abort
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfunc
command! SyntaxEcho call <SID>syntax_echo()


"" :ToggleQuickfix
function! s:toggle_quickfix() abort
    "" https://goo.gl/7B9Dos
    let buffer_count_before = len(filter(
    \   range(1, bufnr('$')), 'buflisted(v:val)'))
    silent! cclose
    let buffer_count_after = len(filter(
    \   range(1, bufnr('$')), 'buflisted(v:val)'))
    if buffer_count_after == buffer_count_before
        execute 'silent! botright copen'
    endif
endfunc
command! ToggleQuickfix call <SID>toggle_quickfix()
nnoremap <silent> yoq :ToggleQuickfix<CR>


"" :ToggleLocation
function! s:toggle_location() abort
    let buffer_count_before = len(filter(
    \   range(1, bufnr('$')), 'buflisted(v:val)'))
    silent! lclose
    let buffer_count_after = len(filter(
    \   range(1, bufnr('$')), 'buflisted(v:val)'))
    if buffer_count_after == buffer_count_before
        execute 'silent! botright lopen'
    endif
endfunc
command! ToggleLocation call <SID>toggle_location()
nnoremap <silent> yok :ToggleLocation<CR>


"" :CleanText
function! s:clean_text() range abort
    exe (a:firstline) . "," . a:lastline . 's/\$/\\$/ge'
    exe (a:firstline) . "," . a:lastline . 's/”/"/ge'
    exe (a:firstline) . "," . a:lastline . 's/“/"/ge'
    exe (a:firstline) . "," . a:lastline . "s/‘/'/ge"
    exe (a:firstline) . "," . a:lastline . "s/’/'/ge"
    exe (a:firstline) . "," . a:lastline . 's/ — /--/ge'
    exe (a:firstline) . "," . a:lastline . 's/—/--/ge'
endfunc
command! -range CleanText <line1>,<line2>call <SID>clean_text()


"" :BackslashReplace
function! s:backslash_replace() range abort
    exe (a:firstline) . "," . a:lastline . 's/\\/\//ge'
endfunc
command! -range BackslashReplace <line1>,<line2>call <SID>backslash_replace()


"" :StripWhitespace
function! s:strip_whitespace() abort
    let m = winsaveview()
    let _s=@/
    exe '%s/\s\+$//e'
    let @/=_s
    call winrestview(m)
endfunc
command! StripWhitespace call <SID>strip_whitespace()


"" :Scratch
function! Scratch(...)
    enew
    file SCRATCH
    setlocal buftype=nofile
    setlocal noswapfile

    if a:0 > 0
        execute 'setlocal filetype=' . a:1
    endif
endfunction

command! -nargs=? Scratch call Scratch(<f-args>)



"" cmdwin + help -------------------------------------------
augroup mjm_misc
    autocmd!
    au CmdwinEnter * nmap <silent><buffer> gq :quit<CR>
    "" needed if <return> is mapped in normal mode
    au CmdwinEnter * nnoremap <CR> <CR>
    au FileType help silent! call <SID>help_quit()
augroup END

function! s:help_quit() abort
    if &ro == 1
        nnoremap exe 'hide'
        nnoremap <silent><buffer> gq :hide<CR>
    endif
endfunction



"" markdown ------------------------------------------------
let g:markdown_fenced_languages = ['r', 'bash=sh', 'vim']

augroup mjm_markdown
    autocmd!
    au BufNewFile,BufRead *.md set ft=markdown
    au FileType markdown setlocal spell spelllang=en_us
    au FileType markdown setlocal commentstring=<!--\ %s\ -->
augroup END



"" rstats --------------------------------------------------
augroup mjm_rstats
    autocmd!
    au FileType rmd setlocal spell spelllang=en_us
    au FileType rmd.markdown setlocal spell spelllang=en_us
    au BufNewFile,BufRead *.rmd set ft=rmd.markdown
    au BufNewFile,BufRead *.stan set ft=cpp
    au FileType r set commentstring=#\ %s
    au FileType r exe 'lua vim.diagnostic.enable(false)'
augroup END



"" diagnostics ---------------------------------------------
command! DiagOff exe 'lua vim.diagnostic.enable(false)'
command! DiagOn  exe 'lua vim.diagnostic.enable(true)'
nnoremap <silent> [d <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d <cmd>lua vim.diagnostic.goto_next()<CR>



"" plug-ins ------------------------------------------------
"" see :h packages
"" - plug-ins are installed in $VIMHOME/pack
""   - loaded at startup:  $VIMHOME/pack/*/start
""   - loaded on :packadd: $VIMHOME/pack/*/opt
""   - colorschemes are always sourced in both /start and /opt
"" - personal lua scripts are stored in $VIMHOME/lua

"" Install plugins if needed
if !isdirectory(stdpath('config') .. '/pack')
    :lua require('pack')
endif

:lua require('lsp')
:lua require('pandoc')
:lua require('floaterminal')
nnoremap <silent>got :<C-U>Floaterminal<CR>

:packadd! vim-commentary
:packadd! vim-eunuch
:packadd! vim-unimpaired


"" flutter
:packadd! plenary.nvim
:packadd! flutter-tools.nvim
:lua require('flutter-tools').setup {}


"" fugitive
:packadd! vim-fugitive
nnoremap <silent> <leader>gg :Gtabedit :<CR>
nnoremap <silent> <leader>gs :Gclog! -g stash<CR>
nnoremap <silent> <leader>gd :Gvdiffsplit<CR>
nnoremap <silent> <leader>gD :Gtdiff<CR>
nnoremap <silent> <leader>ge :Gedit<CR>
command! Gtdiff tabedit %|Gdiff


"" gv
:packadd! gv.vim
nnoremap <silent> <leader>gl :GV --all<CR>


"" oil.nvim
:packadd! oil.nvim
:lua require('oil').setup()
nnoremap <silent> - <cmd>Oil<CR>

augroup mjm_oil
    autocmd!
    au Filetype oil nnoremap <silent><buffer> gq :lua require'oil'.close()<CR>
augroup END


"" sneak
:packadd! vim-sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T


"" easy-align
:packadd! vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
if !exists('g:easy_align_delimiters')
  let g:easy_align_delimiters = {}
endif
let g:easy_align_delimiters['<'] = { 'pattern': '<-' }


"" undo-tree
:packadd! undotree
let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1


"" bufexplorer
:packadd! bufexplorer
" nnoremap <leader>, :BufExplorer<CR>
let g:bufExplorerDefaultHelp = 0
let g:bufExplorerShowRelativePath = 1
let g:bufExplorerSplitBelow = 1
let g:bufExplorerDisableDefaultKeyMapping = 1
let g:bufExplorerShowTabBuffer = 1  "" THIS IS AWESOME!!

function! ToggleBufExplorerTab() abort
    "" Toggle if only tab buffers should be shown
    if g:bufExplorerShowTabBuffer == 1
        let g:bufExplorerShowTabBuffer = 0
    else
        let g:bufExplorerShowTabBuffer = 1
    endif
    normal q
    :BufExplorer
endfunc

augroup mjm_bufexplorer
    autocmd!
    au FileType bufexplorer nmap <silent><buffer> . :call ToggleBufExplorerTab()<CR>
    au FileType bufexplorer nmap <silent><buffer> gq :normal q<CR>
augroup END


"" snippy
:packadd! nvim-snippy
imap <expr> <Tab> snippy#can_expand_or_advance() ? '<Plug>(snippy-expand-or-advance)' : '<Tab>'
imap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
smap <expr> <Tab> snippy#can_jump(1) ? '<Plug>(snippy-next)' : '<Tab>'
smap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'

:lua require('snippy').setup({hl_group = 'diffChanged', enable_auto = false})


"" nss
:lua require('nss')

augroup mjm_nss
    autocmd!
    au FileType r,rmd,rnoweb,julia,rmd.markdown,python call <SID>nss_map_leader()
augroup END
function! s:nss_map_leader() abort
    nnoremap <silent> <leader>mo :<C-U>NSSopen<CR>
    nnoremap <silent> <leader>mq :<C-U>NSSclose<CR>
    nnoremap <leader>mi :NSSinspect 
    xnoremap <leader>mi :NSSinspect 
    nnoremap <silent> <leader>ms :<C-U>NSSsource<CR>
    nnoremap <silent> <leader>mc :<C-U>NSSsend <CR>
    nnoremap <silent> <leader>mx :<C-U>NSSinterrupt<CR>
    if &ft == 'r'
        nnoremap <silent> <leader>ml :<C-U>NSSsource load.R<CR>
    endif
endfunc
if has('unix') || has('macunix')
    :lua vim.g.nss_options = {python = {open_cmd = 'source .venv/bin/activate ; python3'}}
endif

augroup mjm_python
    autocmd!
    au FileType python nnoremap <silent> <leader>mf :!ruff format %<CR>
    au FileType python nnoremap <silent> <leader>mF :!ruff format .<CR>
    au FileType python nnoremap <silent> <leader>mk :!ruff check --fix %<CR>
    au FileType python nnoremap <silent> <leader>mK :!ruff check --fix .<CR>
augroup END


" diffview
:packadd! diffview.nvim
:lua require('diffview').setup()
nnoremap <silent> <leader>dd <cmd>DiffviewOpen<CR>
nnoremap <silent> <leader>dc <cmd>DiffviewClose<CR>
nnoremap <silent> <leader>df <cmd>DiffviewFileHistory<CR>
nnoremap <silent> <leader>dr <cmd>DiffviewRefresh<CR>


"" nvim-web-devicons
:packadd! nvim-web-devicons


"" gitsigns.nvim
:packadd! gitsigns.nvim
:lua require('gitsigns').setup()
nnoremap <silent> [g <cmd>Gitsigns prev_hunk<CR>
nnoremap <silent> ]g <cmd>Gitsigns next_hunk<CR>
nnoremap <silent> <leader>hp <cmd>Gitsigns preview_hunk<CR>
nnoremap <silent> <leader>hi <cmd>Gitsigns preview_hunk_inline<CR>
nnoremap <silent> <leader>hd <cmd>Gitsigns diffthis<CR>
nnoremap <silent> <leader>hs <cmd>Gitsigns stage_hunk<CR>
nnoremap <silent> <leader>hr <cmd>Gitsigns reset_hunk<CR>
nnoremap <silent> <leader>hb <cmd>Gitsigns blame_line<CR>


"" local-highlight
:packadd! local-highlight.nvim
:lua require('local-highlight').setup({animate={enabled=false}})


"" nvim-colorizer
:packadd! nvim-colorizer.lua
:lua require('colorizer').setup({user_default_options={names=false}})


"" nvim-lint
:packadd! nvim-lint
:lua require('lint').linters_by_ft = {python = {'ruff'}}
augroup linters
    autocmd!
    au FileType python lua require('lint').try_lint()
    au BufWritePost * lua require('lint').try_lint()
augroup END


"" blink.cmp
:packadd! blink.cmp
lua << EOF
if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    cols={{"label", "label_description", gap = 1 }, {"kind"}}
else
    cols={{"kind_icon"}, {"label", "label_description", gap = 1 }, {"kind"}}
end
require('blink.cmp').setup({
    fuzzy={implementation="lua"},
    completion={
        menu={
            border="none",
            draw={
                columns=cols,
            },
        },
        documentation = {auto_show = true, auto_show_delay_ms = 500},
    },
})
EOF


"" lualine
:packadd! lualine.nvim
lua << EOF
if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    icons=false
else
    icons=true
end

require('lualine').setup({
    options={
        icons_enabled = icons,
        section_separators = {left = '', right = ''},
        component_separators = {left = '|', right = '|'},
    },
})
EOF


" telescope
:packadd! telescope.nvim
lua << EOF
require('telescope').setup {
  defaults = {
    selection_caret = "→ ",
    preview = {
      hide_on_startup = true,
    },
    sorting_strategy = "ascending",
    layout_config = {
        center = { width = 0.9 },
        prompt_position = "top",
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true
    }
  }
}
EOF

nnoremap <leader><leader> <cmd>Telescope find_files theme=dropdown<CR>
nnoremap <leader>, <cmd>Telescope buffers theme=dropdown<CR>

nnoremap <silent> gof <cmd>Telescope find_files theme=dropdown<CR>
nnoremap <silent> goo <cmd>Telescope oldfiles theme=dropdown<CR>
nnoremap <silent> gol <cmd>Telescope current_buffer_fuzzy_find theme=dropdown<CR>
nnoremap <silent> gob <cmd>Telescope buffers theme=dropdown<CR>
nnoremap <silent> gog <cmd>Telescope live_grep theme=dropdown<CR>
nnoremap <silent> gos <cmd>Telescope highlights theme=dropdown<CR>
nnoremap <silent> goh <cmd>Telescope help_tags theme=dropdown<CR>
nnoremap <silent> goq <cmd>Telescope quickfix theme=dropdown<CR>
nnoremap <silent> goc <cmd>Telescope git_bcommits theme=dropdown<CR>
nnoremap <silent> goC <cmd>Telescope git_commits theme=dropdown<CR>
nnoremap <silent> go/ <cmd>Telescope search_history theme=dropdown<CR>
nnoremap <silent> go; <cmd>Telescope command_history theme=dropdown<CR>
nnoremap <silent> go. <cmd>Telescope resume<CR>


"" testing -------------------------------------------------
