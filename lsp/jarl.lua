---@brief
---
--- https://github.com/etiennebacher/jarl
--- https://jarl.etiennebacher.com/howto/editors

---@type vim.lsp.Config
return {
    cmd = { 'jarl', 'server' },
    filetypes = { 'r', 'rmd' },
    capabilities = {
        general = {
            positionEncodings = { 'utf-16' },
        },
    },
    root_dir = function(bufnr, on_dir)
        on_dir(
            vim.fs.root(bufnr, { '.git', 'jarl.toml', 'DESCRIPTION', '.Rproj' })
            or vim.uv.os_homedir()
        )
    end,
}
