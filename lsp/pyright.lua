---@brief
---
--- https://github.com/microsoft/pyright
--- Install: brew install pyright

---@type vim.lsp.Config
return {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'pyrightconfig.json',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
    },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'openFilesOnly',
                useLibraryCodeForTypes = true,
            },
        },
        pyright = {
            -- Hand off import organization to ruff
            disableOrganizeImports = true,
        },
    },
}
