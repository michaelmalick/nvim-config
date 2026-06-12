-- LSP config file
-- Michael Malick
--
-- Language specific LSP configs are in .config/nvim/lsp
--
-- Setting up a language server is a two-step process:
--  1. Manually install language server outside of nvim
--  2. Setup LSP for the language in nvim
--
-- See also: https://github.com/neovim/nvim-lspconfig
--
-- :checkhealth vim.lsp


-- Enable LSP
vim.lsp.enable('r_language_server')
vim.lsp.enable('jarl') -- linting
vim.lsp.enable('pyright')
vim.lsp.enable('ruff') -- linting
vim.lsp.enable('lua_ls')


-- Diagnostic config
vim.diagnostic.config({
  virtual_lines = { current_line = true },
  underline = false,
  severity_sort = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN]  = '▲',
      [vim.diagnostic.severity.INFO]  = 'ℹ',
      [vim.diagnostic.severity.HINT]  = '⚑',
    },
  },
})


-- LSP attaching
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('mjm_lsp', { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- Turn off semantic-token syntax in R buffers
        if client and client.name == 'r_language_server' then
            client.server_capabilities.semanticTokensProvider = nil
        end

        -- Defer hover to r_language_server so jarl doesn't compete
        if client and client.name == 'jarl' then
            client.server_capabilities.hoverProvider = false
        end

        -- Defer hover to pyright, which has actual type info
        if client and client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
        end

        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- If attached LSP supports completion, add it to native engine
        if client and client:supports_method('textDocument/completion') then
          vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end

        -- Buffer local mappings
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<leader>ld', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>lc', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>lh', vim.lsp.buf.signature_help, opts)
    end,
})
