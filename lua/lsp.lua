-- LSP config file
-- Michael Malick
--
-- Neovim built-in LSP config
-- Using 'neovim/nvim-lspconfig' to ease setup of LSP
--
-- Setting up a language server is a two-step process:
--  1. Manually install language server outside of nvim
--  2. Setup LSP for the language in init.vim
--
--  See also: https://github.com/neovim/nvim-lspconfig
--            https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
--
-- julia: using Pkg; Pkg.add("LanguageServer")
-- r: install.packages("languageserver")
-- lua: on MacOS -> brew install lua-language-server
--      on Windows -> scoop install lua-language-server
--      or download binaries -> https://github.com/sumneko/lua-language-server/releases (put in path)
-- pyright: on Windows -> scoop install node js; npm install -g pyright
--          on MacOS -> brew install pyright

vim.cmd('packadd! nvim-lspconfig')


-- R setup
vim.lsp.enable('r_language_server')

-- Python setup
vim.lsp.enable('pyright')

-- Lua setup
vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = {'vim'},
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
})




-- LspAttach autocommand
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('mjm_lsp', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    end,
})
