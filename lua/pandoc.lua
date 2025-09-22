-- Useful pandoc functions

function Pandoc_run(ext)
    if vim.fn.executable('pandoc') == 1 then
        local path1 = vim.fn.fnameescape(vim.fn.expand('%:p:r'))
        local path2 = vim.fn.fnameescape(vim.fn.expand('%:p'))

        local cmd = string.format('!pandoc --citeproc -o %s.%s %s', path1, ext, path2)
        vim.cmd(cmd)
    else
        vim.api.nvim_echo({
            {'Error: pandoc not found', 'WarningMsg'}
        }, true, {})
    end
end

-- Create the user command
vim.api.nvim_create_user_command('Pandoc', function(opts)
    Pandoc_run(opts.args)
end, {
    nargs = 1,
    desc = 'Convert current file using pandoc to specified format'
})
