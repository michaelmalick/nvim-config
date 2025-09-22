-- Package bootstrap + update
-- Michael Malick
-- source file: 'luafile %'

local repos = {'jlanzarotta/bufexplorer',
               'junegunn/gv.vim',
               'dcampos/nvim-snippy',
               'mbbill/undotree',
               'tpope/vim-commentary',
               'justinmk/vim-dirvish',
               'junegunn/vim-easy-align',
               'tpope/vim-eunuch',
               'tpope/vim-fugitive',
               'justinmk/vim-sneak',
               'tpope/vim-unimpaired',
               'nordtheme/vim',
               'morhetz/gruvbox',
               'neovim/nvim-lspconfig',
               'nvim-lua/plenary.nvim',
               'nvim-flutter/flutter-tools.nvim',
               'junegunn/vader.vim',
               --
               'tzachar/local-highlight.nvim',
               'catgoose/nvim-colorizer.lua',
               'lewis6991/gitsigns.nvim',
               'saghen/blink.cmp',
               'nvim-tree/nvim-web-devicons',
               'nvim-lualine/lualine.nvim',
               'ibhagwan/fzf-lua',
               'mfussenegger/nvim-lint',
               'stevearc/oil.nvim',
               'nvim-telescope/telescope.nvim',
               'sindrets/diffview.nvim',
           }


local url = 'https://github.com/'
local dir = vim.fn.stdpath('config') .. '/pack/ext/opt'
if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, 'p') end


for i = 1,#repos do
    local parts = vim.split(repos[i], "/")

    if vim.fn.isdirectory(dir .. "/" .. parts[2]) == 1 then
        -- plugin exists; git pull
        vim.api.nvim_echo({{'Updating ' .. repos[i]}}, true, {})
        os.execute('cd ' .. dir .. '/' .. parts[2] .. ' && git pull')
    else
        -- plugin doesn't exist; git clone
        vim.api.nvim_echo({{'Cloning ' .. repos[i]}}, true, {})
        os.execute('cd ' .. dir .. ' && git clone ' .. url .. repos[i])
    end
end
