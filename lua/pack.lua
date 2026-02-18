-- Package bootstrap + update
-- Michael Malick
-- source file: 'luafile %'

local repos = {
    'junegunn/gv.vim',
    'dcampos/nvim-snippy',
    'tpope/vim-commentary',
    'junegunn/vim-easy-align',
    'tpope/vim-eunuch',
    'tpope/vim-fugitive',
    'justinmk/vim-sneak',
    'tpope/vim-unimpaired',
    'neovim/nvim-lspconfig',
    'nvim-lua/plenary.nvim',
    'akinsho/toggleterm.nvim',
    'tzachar/local-highlight.nvim',
    'catgoose/nvim-colorizer.lua',
    'lewis6991/gitsigns.nvim',
    'nvim-tree/nvim-web-devicons',
    'nvim-lualine/lualine.nvim',
    'mfussenegger/nvim-lint',
    'stevearc/oil.nvim',
    'nvim-telescope/telescope.nvim',
    'saghen/blink.cmp',

}


local url = 'https://github.com/'
local dir = vim.fn.stdpath('data') .. '/site/pack/ext/opt'
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
