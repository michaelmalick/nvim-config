-- Neovim Speaks Statistics
--
-- Three main dicts store the state of NSS:
--    nss.scripts            dict w/ one entry for each NSS script buffer
--    nss.targets            dict w/ one entry for each NSS target buffer
--    vim.g.nss_options      default + user specified NSS options
-- Set buffer specific variables using:
--    nss.set_script_var
--    nss.set_target_var
-- Get buffer specific variables using:
--    nss.get_script_var
--    nss.get_target_var
--
-- TODO check that r and julia are in path
-- TODO rmd text objects
-- TODO send register (gd"[reg])
-- TODO rename target buffer
-- TODO explore treesitter text objects
-- TODO restart command
-- TODO explore qmd support (multiple targets)
--  nss_options.qmd.dialect_default = 'r'
--  set dialect when calling an nss function
--  dispatch correct method based on dialect

local api = vim.api
local nss = {scripts = { },
             targets = { }}

-- Utils ---------------------------------------------------
local function echohl(str, hl)
    --- Echo a highlighted message.
    -- @param str (string) string to highlight
    -- @param hl (string) highlighting group, default: 'WarningMsg'
    hl = hl or 'WarningMsg'
    assert(type(str) == 'string', 'Expected a string.')
    assert(type(hl) == 'string', 'Expected a string.')

    api.nvim_echo({{str, hl}}, true, {})
end

local function remove_duplicates(tbl)
    --- Remove duplicate elements from a table.
    -- @param tbl (table) table for which duplicates should be removed
    -- @return the input table with duplicates removed
    -- This function doesn't work if elements of input table are tables
    local hash = { }
    local result = { }
    for _,v in ipairs(tbl) do
        if (not hash[v]) then
            table.insert(result, v)
            hash[v] = true
        end
    end

    return result
end

function nss.is_registered(bufnr)
    --- Test if buffer is registered with NSS.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @return logical, true if it is registered, false otherwise
    assert(type(bufnr) == 'number', 'Expected a number.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end
    local out = false
    if nss.scripts[bufnr] then out = true end
    return out
end

function nss.has_target(bufnr)
    --- Test if buffer has a target processs attached.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @return true if bufnr has a target attached, nil otherwise
    assert(type(bufnr) == 'number', 'Expected a number.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end

    if nss.get_script_var(bufnr, 'target_id') then
        return true
    end
end

function nss.has_channel(bufnr)
    --- Test if buffer has a channel.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @return true if bufnr has a channel id, nil otherwise
    if not bufnr or not api.nvim_buf_is_loaded(bufnr) then
        return
    end
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end

    if api.nvim_get_option_value('channel', {buf = bufnr}) > 0 then
        return true
    end
end

function nss.get_channel_buffers(names)
    --- Get table of channel buffers.
    -- @param name (boolean) if true return buffer names, otherwise buffer numbers
    -- @return table of buffers with channels
    local tbl = { }
    local bufs = api.nvim_list_bufs()
    for i = 1,#bufs do
        if nss.has_channel(bufs[i]) then
            if names then
                table.insert(tbl, api.nvim_buf_get_name(bufs[i]))
                -- table.insert(tbl, vim.fn.bufname(bufs[i]))
            else
                table.insert(tbl, bufs[i])
            end
        end
    end
    return tbl
end

function nss.target_exists(bufnr)
    --- Test if buffer's target still exists.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    assert(type(bufnr) == 'number', 'Expected a number.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end

    local target_bufnr = nss.get_script_var(bufnr, 'target_bufnr')

    if api.nvim_buf_is_loaded(target_bufnr) then
        return true
    end
end

-- TODO should these be buffer local?
function nss.save_view()
    --- Save window view.
    nss.win_view = vim.fn.winsaveview()
end

function nss.restore_view()
    --- Restore window view
    if nss.win_view then
        vim.fn.winrestview(nss.win_view)
        nss.win_view = nil
    end
end

function nss.write_tmpfile(tbl)
    --- Write lines to a temp file.
    -- @param tbl (table) table of lines to write
    -- @return file path lines were written too
    assert(type(tbl) == 'table', 'Expected a table.')
    local tmp = nss.get_script_var(0, 'tmpfile')
    if not tmp then return end
    local file = io.open(tmp, "w")
    for i = 1,#tbl do
        file:write(tbl[i], "\n")
    end
    io.close(file)
    return tmp
end

function nss.prompt_jump(backward)
    --- Jump to prev or next prompt in terminal buffer.
    -- @param backward (boolean) if true jump backward, otherwise jump forward
    local flags
    if not backward then flags = 'bW' else flags = 'W' end

    local dialect = nss.get_target_var(0, 'dialect')
    local prompt = vim.g.nss_options[dialect]['prompt']

    vim.cmd([[normal! 0]])
    vim.fn.search(prompt, flags)
end

function nss.get_target_buffers(dialect)
    --- Get table of target buffer numbers for a dialect.
    -- @param dialect (string) lang dialect to find targets for
    -- @return (table) target bufnr or nil if no suitable targets were found
    if not nss.scripts or #nss.scripts < 1 then
        return
    end

    local buf = { }
    for k,v in pairs(nss.scripts) do  -- don't use ipairs here
        if nss.get_script_var(k, 'dialect') == dialect then
            table.insert(buf, v.target_bufnr)
        end
    end

    if #buf == 0 then return end

    -- get unique buffer numbers
    local result = remove_duplicates(buf)

    return result
end

function nss.clean_lines(lines)
    --- Clean text prior to sending
    ---  1. Remove common leading whitespace
    --   2. Only allow a single blank line to be sent.
    --      Julia terminates functions,forloops, etc if two CR's are sent
    -- @param lines table of strings
    -- @return table of strings
    assert(type(lines) == 'table', 'Expected a table.')

    lines = nss.remove_leading_whitespace(lines)

    if #lines < 3 then return lines end
    local clean = { }
    local len_prev = 1
    for i = 1,#lines do
        if len_prev == 0 and #lines[i] == 0 then goto continue end
        table.insert(clean, lines[i])
        ::continue::
        len_prev = #lines[i]
    end
    return clean
end

-- function nss.is_error(prompt_line, bufnr)
--     -- local line = api.nvim_buf_get_lines(bufnr, prompt_line - 1, -1, false)
--     -- print(prompt_line)
--     -- if string.find(line[1], '^Error:') then return true end
--     if string.find(prompt_line, '^Error:') then return true end
-- end

function nss.clean_filepath(txt)
    --- Clean filepath.
    -- On Windows this will replace \ with /
    -- @param txt (string) filepath to clean
    if vim.fn.has('win32') or vim.fn.has('win64') then
        txt = string.gsub(txt, '\\', '/')
    end
    return txt
end

function nss.bracketed_paste(lines)
    --- Bracketed paste
    -- start: ESC [ 200 ~
    -- end:   ESC [ 201 ~
    -- see: https://cirw.in/blog/bracketed-paste

    local bp_start = [[ \27[200~ ]]
    local bp_end = [[ \27[201~ ]]

    local out
    if #lines == 1 then
        out = lines
    else
        out = {bp_start .. lines[1]}
        for i = 2,#lines do
            table.insert(out, lines[i])
        end

        table.insert(out, bp_end)
    end

    return out
end

function nss.remove_leading_whitespace(lines)
    --- Remove any leading whitespace from table of lines
    if not lines or #lines == 0 then
      return lines
    end

    local first_line = lines[1]

    local leading_whitespace = first_line:match("^(%s*)")

    if leading_whitespace == "" then
      return lines
    end

    local whitespace_count = #leading_whitespace

    -- Create a new table with whitespace removed from each line
    local result = {}
    for i, line in ipairs(lines) do
      -- Remove the same amount of leading whitespace from each line
      -- If line has less whitespace than needed, just remove what's available
      local line_leading = line:match("^(%s*)")
      local to_remove = math.min(#line_leading, whitespace_count)
      result[i] = line:sub(to_remove + 1)
    end

    return result
end

function nss.delete_tmpfile(bufnr, all)
    --- Delete temporary files used for source sending
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @param all (boolean) should tmp files be removed for all buffers
    assert(type(bufnr) == 'number', 'Expected a number.')
    if not nss.scripts then return end
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end

    if all then
        -- delete tmp file for all buffers
        for k,_ in pairs(nss.scripts) do  -- don't use ipairs here
            local tmp = nss.get_script_var(k, 'tmpfile')
            if tmp then
                os.remove(tmp)
            end
        end
    else
        -- delete tmp file only for current buffer
        local tmp = nss.get_script_var(0, 'tmpfile')
        if tmp then
            os.remove(tmp)
        end
    end
end



-- Vars ----------------------------------------------------
function nss.set_script_var(bufnr, name, value)
    --- Set an NSS script variable.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @param name (string) name of variable
    -- @param value (string) value of variable
    assert(type(bufnr) == 'number', 'Expected a number.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end
    if not nss.scripts[bufnr] then nss.scripts[bufnr] = { } end
    nss.scripts[bufnr][name] = value
end

function nss.get_script_var(bufnr, name)
    --- Get an NSS script variable.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @param name (string) name of variable
    assert(type(bufnr) == 'number', 'Expected a number.')
    assert(type(name) == 'string', 'Expected a string.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end
    if not nss.scripts[bufnr] then return end
    return nss.scripts[bufnr][name]
end

function nss.set_target_var(bufnr, name, value)
    --- Set an NSS target variable.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @param name (string) name of variable
    -- @param value (string) value of variable
    assert(type(bufnr) == 'number', 'Expected a number.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end
    if not nss.targets[bufnr] then nss.targets[bufnr] = { } end
    nss.targets[bufnr][name] = value
end

function nss.get_target_var(bufnr, name)
    --- Get an NSS target variable.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @param name (string) name of variable
    assert(type(bufnr) == 'number', 'Expected a number.')
    assert(type(name) == 'string', 'Expected a string.')
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end
    if not nss.targets[bufnr] then return end
    return nss.targets[bufnr][name]
end



-- Register ------------------------------------------------
function nss.register_script(dialect)
    --- Initialize NSS for a script buffer.
    -- Should be called when entering an NSS script buffer
    -- @param dialect (string) language dialect to initiate
    if nss.get_script_var(0, 'dialect') then return end

    nss.set_script_var(0, 'dialect', dialect)
    nss.set_script_var(0, 'tmpfile', os.tmpname())
    nss.auto_attach(dialect)  -- need to call after setting script dialect
    nss.keymaps()
end

function nss.register_target(dialect, bufnr, id)
    --- Initialize NSS for a target buffer.
    -- Should be called when in an NSS target buffer
    -- @param dialect (string) language dialect to initiate
    -- @param bufnr (number) buffer handle for target process
    -- @param id (number) channel id
    assert(type(bufnr) == 'number', 'Expected a number.')
    assert(type(id) == 'number', 'Expected a number.')

    if dialect == 'r' and vim.g.nss_options.r.highlight_term then
        vim.bo.syntax = 'rterm'
    end

    nss.set_target_var(0, 'dialect', dialect)
    nss.set_target_var(0, 'bufnr', bufnr)
    nss.set_target_var(0, 'id', id)
    local kopts = {noremap = true, silent = true}
    api.nvim_buf_set_keymap(0, 'n', '[[', ':lua require"nss".prompt_jump()<CR>', kopts)
    api.nvim_buf_set_keymap(0, 'n', ']]', ':lua require"nss".prompt_jump(1)<CR>', kopts)
end



-- Attach --------------------------------------------------
function nss.attach_command(buffer)
    --- Function for :NSSattach command.
    -- @param buffer (string) target buffer name to attach
    local bufnum = vim.fn.bufnr(buffer)
    nss.attach(bufnum)
end

function nss.attach(target_bufnr, script_bufnr, id)
    --- Attach a target/channel to current buffer.
    -- @param target_bufnr (number) process buffer handle
    -- @param script_bufnr (number) script buffer handle, if nil current buffer is used
    -- @param id (number) channel id, if nil channel id of 'target_bufnr' is used
    if not nss.has_channel(target_bufnr) then
        echohl("NSS: target does not have a channel")
        return
    end

    script_bufnr = script_bufnr or api.nvim_get_current_buf()
    if not nss.is_registered(script_bufnr) then
        echohl('NSS: not a supported filetype buffer')
        return
    end

    id = id or api.nvim_get_option_value('channel', {buf = target_bufnr})
    nss.set_script_var(script_bufnr, 'target_bufnr', target_bufnr)
    nss.set_script_var(script_bufnr, 'target_id', id)
end

function nss.auto_attach(dialect)
    --- Auto attach a target if only one target buffer for the dialect exists.
    -- @param dialect (string) dialect to find targets for
    if nss.has_target(0) then return end

    local target = nss.get_target_buffers(dialect)
    if target and #target == 1 then
        nss.attach(target[1])
    end
end



-- Detach --------------------------------------------------
function nss.detach(bufnr, all)
    --- Detach a target/channel from current (or all) buffer.
    -- @param bufnr (number) buffer handle or 0 for current buffer
    -- @param all (boolean) should target be removed for all buffers
    assert(type(bufnr) == 'number', 'Expected a number.')
    if not nss.scripts then return end
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end

    if not nss.has_target(bufnr) then
        echohl('NSS: no target to detach')
        return
    end

    if all then
        -- detach target for all buffers
        local target_bufnr = nss.get_script_var(bufnr, 'target_bufnr')
        for k,_ in pairs(nss.scripts) do  -- don't use ipairs here
            local ct = nss.get_script_var(k, 'target_bufnr')
            if ct == target_bufnr then
                nss.set_script_var(k, 'target_bufnr', nil)
                nss.set_script_var(k, 'target_id', nil)
            end
        end
    else
        -- detach target only for current buffer
        nss.set_script_var(bufnr, 'target_bufnr', nil)
        nss.set_script_var(bufnr, 'target_id', nil)
    end
end

-- function nss.detach_target(target_bufnr)
--     --- Detach a target buffer from all scripts
--     --- @param target_bufnr (number) target buffer number to detach
--     assert(type(target_bufnr) == 'number', 'Expected a number.')
--     if not nss.scripts then return end
--     for k,v in pairs(nss.scripts) do  -- don't use ipairs here
--         -- print(k)
--         local ct = nss.get_script_var(k, 'target_bufnr')
--         if ct == target_bufnr then
--             nss.detach(k)
--         end
--     end
-- end



-- Open / Close --------------------------------------------
function nss.open(cmd)
    --- Open and attach a new process target buffer.
    -- @param cmd (string) command to open a new buffer and window
    --   (default: 'vim.g.nss_options.win_cmd')
    cmd = cmd or vim.g.nss_options.win_cmd
    assert(type(cmd) == 'string', 'Expected a string.')

    local start_winid = api.nvim_get_current_win()
    local start_bufnr = api.nvim_get_current_buf()

    if not nss.is_registered(start_bufnr) then
        echohl('NSS: not a supported filetype buffer')
        return
    end

    local bufs_start = api.nvim_list_bufs()
    api.nvim_command(cmd)
    local target_bufnr = api.nvim_get_current_buf()
    local bufs_end = api.nvim_list_bufs()

    if #bufs_start == #bufs_end then
        echohl('NSS: command did not create a new buffer')
        return
    end

    local vars = nss.scripts[start_bufnr]
    local open_cmd = vim.g.nss_options[vars.dialect]['open_cmd']
    local id = vim.fn.jobstart(open_cmd, {term = true})
    nss.register_target(vars.dialect, target_bufnr, id)

    api.nvim_set_current_win(start_winid)
    nss.attach(target_bufnr, start_bufnr, id)
end

function nss.close_target(dialect, bufnr, id)
    --- Close target process and buffer
    -- @param dialect (string) language dialect to initiate
    -- @param bufnr (number) buffer handle for target process
    -- @param id (number) channel id
    assert(type(dialect) == 'string', 'Expected a string.')
    assert(type(bufnr) == 'number', 'Expected a number.')
    assert(type(id) == 'number', 'Expected a number.')

    if not api.nvim_buf_is_loaded(bufnr) then return end
    if not nss.has_channel(bufnr) then return end

    local cr = string.char(13)
    local cmd = vim.g.nss_options[dialect].exit_cmd
    api.nvim_chan_send(id, cmd .. cr)
    vim.cmd([[sleep 5m]]) -- needed so that Rtmp dir is deleted on Windows
    -- 2. close channel
    vim.fn.chanclose(id)
    -- 3. delete buffer
    api.nvim_buf_delete(bufnr, {force = true, unload = false})
    -- 4. clean-up targets table
    nss.targets[bufnr] = nil
end

function nss.close_attached_target(bufnr)
    --- Close terminal process buffer attached to script
    -- @param bufnr (number) buffer handle or 0 for current buffer
    assert(type(bufnr) == 'number', 'Expected a number.')
    if not nss.scripts then return end
    if bufnr == 0 then bufnr = api.nvim_get_current_buf() end

    if not nss.has_target(bufnr) then
        echohl('NSS: no target attached to close')
        return
    end

    local target_bufnr = nss.get_script_var(bufnr, 'target_bufnr')
    local target_id = nss.get_script_var(bufnr, 'target_id')
    local dialect = nss.scripts[bufnr]['dialect']

    nss.close_target(dialect, target_bufnr, target_id)
    nss.detach(bufnr, true)
end

function nss.close_all_targets()
    --- Close all target processes and buffers
    if not nss.targets then return end

    for k,_ in pairs(nss.targets) do  -- don't use ipairs here
        local dialect = nss.get_target_var(k, 'dialect')
        local bufnr = nss.get_target_var(k, 'bufnr')
        local id = nss.get_target_var(k, 'id')
        if bufnr then
            nss.close_target(dialect, bufnr, id)
        end
    end

end



-- Regions -------------------------------------------------
function nss.marked_region(mark1, mark2, mode)
    --- Get inputs to `vim.region` for region between two marks.
    -- @param mark1 (string) start mark for region
    -- @param mark2 (string) end mark for region
    -- @param mode (string) type of visual mode, see :h visualmode()
    -- @return table with keys:
    --   bufnr: current buffer number
    --   pos1: {line, column} of mark1
    --   pos2: {line, column} of mark2
    --   mode: visual mode
    --   inclusive: boolean specifying if region positions are inclusive
    assert(type(mark1) == 'string', 'Expected a string.')
    assert(type(mark2) == 'string', 'Expected a string.')
    assert(type(mode) == 'string', 'Expected a string.')

    local pos1 = vim.fn.getpos(mark1)
    local pos2 = vim.fn.getpos(mark2)
    pos1 = {pos1[2] - 1, pos1[3] - 1 + pos1[4]}
    pos2 = {pos2[2] - 1, pos2[3] - 1 + pos2[4]}

    -- Return if start or finish are invalid
    if pos1[2] < 0 or pos2[1] < pos1[1] then return end

    -- Handle blockwise mode
    -- BUG: when block starts in topright or bottomleft the correct text isn't
    -- sent. As far as I can tell, this is a bug in vim.region
    if string.byte(mode) == 22 and #mode == 1 then
        local width = math.abs(pos2[2] - pos1[2]) + 1
        mode = [[]] .. width
    end

    -- Get current buffer number
    local bufnr = api.nvim_get_current_buf()

    -- Linewise: capture entire start and finish lines
    if mode == 'V' then
        local lines = api.nvim_buf_get_lines(bufnr, pos1[1], pos2[1] + 1, false)
        pos1[2] = 0
        pos2[2] = #lines[#lines]
    end

    return {bufnr = bufnr,
            pos1 = pos1,
            pos2 = pos2,
            mode = mode,
            inclusive = (vim.o.selection ~= 'exclusive')}
end

function nss.get_marked_text(mark1, mark2, mode)
    --- Get text in region between two marks.
    -- @param mark1 (string) start mark for region
    -- @param mark2 (string) end mark for region
    -- @param mode (string) type of visual mode, see :h visualmode()
    -- @return table of lines for region marked by 'mark1' and 'mark2'

    local m = nss.marked_region(mark1, mark2, mode)
    if not m then return end

    local region = vim.region(m.bufnr,
                              m.pos1,
                              m.pos2,
                              m.mode,
                              m.inclusive)

    -- Get lines in region
    local lines = api.nvim_buf_get_lines(m.bufnr, m.pos1[1], m.pos2[1] + 1, false)

    -- charwise and blockwise
    if mode ~= 'V' then
        local I = m.pos1[1]
        for i = 1,#lines do
            local c1 = region[I][1] + 1
            local c2 = region[I][2]
            lines[i] = string.sub(lines[i], c1, c2)
            I = I + 1
        end
    end

    return lines
end

function nss.blink_region(mark1, mark2, mode, opts)
    --- Blink highlight in region between two marks.
    -- @param mark1 (string) start mark for region
    -- @param mark2 (string) end mark for region
    -- @param mode (string) type of visual mode, see :h visualmode()
    -- @parm opts = table of option with keys:
    --    higroup = highlight group for blink (default: 'IncSearch')
    --    timeout = time in ms to blink for (default: 150)
    --    priority = highlight priority (default: vim.highlight.priorities.user)
    opts = opts or {}

    local m = nss.marked_region(mark1, mark2, mode)
    if not m then return end

    local send_ns = api.nvim_create_namespace('nss_hlsend')
    local higroup = opts.higroup or vim.g.nss_options.blink.higroup
    local timeout = opts.timeout or vim.g.nss_options.blink.timeout
    local priority = opts.priority or vim.g.nss_options.blink.priority
    api.nvim_buf_clear_namespace(m.bufnr, send_ns, 0, -1)

    vim.highlight.range(m.bufnr,
                        send_ns,
                        higroup,
                        m.pos1,
                        m.pos2,
                        {regtype = m.mode,
                         inclusive = m.inclusive,
                         priority = priority})

    -- Clear timer
    local blink_timer
    if blink_timer then
        blink_timer:close()
    end

    -- Set timer
    blink_timer = vim.defer_fn(function()
        blink_timer = nil
        if api.nvim_buf_is_valid(m.bufnr) then
            api.nvim_buf_clear_namespace(m.bufnr, send_ns, 0, -1)
        end
    end, timeout)
end



-- Send ----------------------------------------------------
function nss.send_text(txt)
    --- Send text to target process.
    -- @param txt (table) table of strings or a string
    if not txt then return end

    local bufnr = api.nvim_get_current_buf()
    local dialect = nss.scripts[bufnr]['dialect']
    local send_type = vim.g.nss_options[dialect].send_type

    if not nss.has_target(0) then
        -- try attaching to existing target
        nss.auto_attach(dialect)
        if not nss.has_target(0) then
            echohl('NSS: no target available to attach')
            return
        end
    end

    if not nss.target_exists(0) then
        echohl('NSS: target does not exist...detaching')
        nss.detach(0, true)
        return
    end


    if type(txt) == 'number' then txt = tostring(txt) end
    if type(txt) == 'string' then txt = {txt} end


    local chan = nss.get_script_var(0, 'target_id')
    local cr = string.char(13)

    if #txt == 1 then
        api.nvim_chan_send(chan, txt[1] .. cr)
        return
    end

    if send_type == 'lines' then
        for i = 1,#txt do
            api.nvim_chan_send(chan, txt[i] .. cr)
            vim.cmd([[sleep 1m]])
        end
        return
    end

    if send_type == 'source' then
        local file = nss.write_tmpfile(txt)
        nss.source(file)
        return
    end

    if send_type == 'bracketed' then
        local bt = nss.bracketed_paste(txt)
        for i = 1,#bt do
            api.nvim_chan_send(chan, bt[i] .. cr)
            vim.cmd([[sleep 1m]])
        end
        return
    end
end

function nss.send_visual()
    --- Send visual selection to target process.

    -- if not nss.has_target(0) then
    --     echohl('NSS: no target attached (vis)')
    --     return
    -- end

    -- '< '> marks are not set until after you leave the selection
    vim.cmd([[normal! \<Esc>]])
    local vmode = vim.fn.visualmode()
    local lines = nss.get_marked_text("'<", "'>", vmode)
    local clean = nss.clean_lines(lines)
    nss.send_text(clean)
    nss.blink_region("'<", "'>", vmode)
end

function nss.send_opfunc(mode)
    --- Send text object to target process.
    -- @param mode (string) mode for region
    -- @see :h g@
    -- @see :h setreg
    local vmode

    if not mode then
        nss.save_view() -- TODO make this optional?
        vim.opt.opfunc = '__nss_opfunc'
        return 'g@'
    elseif mode == 'line' then
        vmode = 'V'
    elseif mode == 'block' then
        vmode = ''
    else -- 'char'
        vmode = 'v'
    end

    -- if not nss.has_target(0) then
    --     echohl('NSS: no target attached (opt)')
    --     nss.restore_view()
    --     return
    -- end

    local lines = nss.get_marked_text("'[", "']", vmode)
    local clean = nss.clean_lines(lines)
    nss.send_text(clean)
    nss.blink_region("'[", "']", vmode)

    nss.restore_view()
end

function nss.send_command(tbl)
    --- Function for :NSSsend command
    -- @param tbl (table) see 'nvim_create_user_command'
    local line1 = tbl.line1
    local line2 = tbl.line2
    local args = tbl.args

    if tbl.args == '' then
        local lines = api.nvim_buf_get_lines(0, line1 - 1, line2, false)
        nss.send_text(lines)
    else
        nss.send_text(args)
    end
end



-- Inspect -------------------------------------------------
-- function nss.inspect(visual)
--     --- Wrap text in user supplied function call and send to process.
--     --- @param visual (boolean) true if visual selection should be used
--     ---   otherwise <cword> is used
--     local word
--     if visual then
--         vim.cmd([[normal! \<Esc>]])
--         local lines = nss.get_marked_text("'<", "'>", vim.fn.visualmode())
--         word = lines[1]
--     else
--         word = vim.fn.expand("<cword>")
--     end
--     vim.fn.inputsave()
--
--     local default
--     if not nss.wrap_history then
--         nss.wrap_history = { }
--         default = ''
--     else
--         default = nss.wrap_history[1]
--     end
--
--     -- TODO can add completion here
--     local func = vim.fn.input("Function: ", default)
--     vim.fn.inputrestore()
--     if func == '' then return end
--     local text = func .. '(' .. word .. ')'
--     nss.send_text({text})
--     table.insert(nss.wrap_history, 1, func)
-- end

function nss.inspect(func, visual)
    --- Wrap text in user supplied function call and send to process.
    -- @param func (string) function name to wrap text with
    -- @param visual (boolean) true if visual selection should be used
    --   otherwise <cword> is used

    local bufnr = api.nvim_get_current_buf()
    if not nss.is_registered(bufnr) then
        echohl('NSS: not a supported filetype buffer')
        return
    end

    local word
    if visual then
        vim.cmd([[normal! \<Esc>]])
        local lines = nss.get_marked_text("'<", "'>", vim.fn.visualmode())
        word = lines[1]
    else
        word = vim.fn.expand("<cword>")
    end

    if func == '' or not func then return end

    -- save func to inspect_history table
    local dialect = nss.scripts[bufnr]['dialect']
    table.insert(nss.inspect_history[dialect], 1, func)
    nss.inspect_history[dialect] = remove_duplicates(nss.inspect_history[dialect])

    local text = func .. '(' .. word .. ')'
    nss.send_text({text})
end



-- Source --------------------------------------------------
function nss.source(file)
    --- Source a file in target process.
    -- Target attached to current buffer is used
    -- @param file (string) file to source, if nil current buffer file is used
    if not file then file = api.nvim_buf_get_name(0) end
    local bufnr = api.nvim_get_current_buf()

    if not nss.is_registered(bufnr) then
        echohl('NSS: not a supported filetype buffer')
        return
    end

    local dialect = nss.scripts[bufnr]['dialect']
    local cmd = vim.g.nss_options[dialect].source_cmd

    local clean = nss.clean_filepath(file)
    local txt = string.format(cmd, clean)
    nss.send_text(txt)
end


-- Use a vim function so the . operator works properly
-- see: https://github.com/neovim/neovim/issues/17503
vim.cmd [[
    function! __nss_opfunc(mode, ...) abort
        return v:lua.require'nss'.send_opfunc(a:mode)
    endfunction
]]

function nss.keymaps()
    local key_motion = vim.g.nss_options.keys.motion
    local key_visual = vim.g.nss_options.keys.visual
    local key_line   = vim.g.nss_options.keys.line

    if(key_motion ~= '') then
        api.nvim_buf_set_keymap(0, 'n', key_motion,
            [[v:lua.require'nss'.send_opfunc()]],
            {noremap = true, expr = true})
    end

    if(key_visual ~= '') then
        api.nvim_buf_set_keymap(0, 'x', key_visual,
            [[:<C-U>lua require'nss'.send_visual()<CR>]],
            {noremap = true, silent = true})
    end

    if(key_line ~= '') then
        api.nvim_buf_set_keymap(0, 'n', key_line,
            [[v:lua.require'nss'.send_opfunc() .. '_']],
            {noremap = true, expr = true})
    end
end



-- Commands ------------------------------------------------

-- :NSSsend
api.nvim_create_user_command("NSSsend", function(tbl)
    nss.send_command(tbl)
end, {
    nargs = '?',
    range = true,
})

-- :NSSattach
api.nvim_create_user_command("NSSattach", function(tbl)
    nss.attach_command(tbl.args)
end, {
    nargs = 1,
    complete = function(lead, line, pos)
        local bufs = nss.get_channel_buffers(true)
        local matches = vim.tbl_filter(function(val)
                return vim.startswith(val, lead)
            end, bufs)
        return matches
end,
})

-- :NSSopen
-- TODO: specify cmd args + window location
api.nvim_create_user_command("NSSopen", function(tbl)
    if tbl.args == '' then
        nss.open()
    else
        nss.open(tbl.args)
    end
end, {
    nargs = '*',
})

-- :NSSclose
api.nvim_create_user_command("NSSclose", function()
        nss.close_attached_target(0)
end, {
    nargs = 0,
})

-- :NSSdetach(!)
api.nvim_create_user_command("NSSdetach", function(tbl)
    if tbl.bang then
        nss.detach(0, true)
    else
        nss.detach(0)
    end
end, {
    nargs = 0,
    bang = true,
})

-- :NSSsource
api.nvim_create_user_command("NSSsource", function(tbl)
    local args = tbl.args
    if args == '' then args = nil end
    nss.source(args)
end, {
    nargs = '?',
    complete = 'file',
})

-- :NSSinterrupt
api.nvim_create_user_command("NSSinterrupt", function(tbl)
    nss.send_text(string.char(03))
end, {
    nargs = 0,
})

-- :NSSinspect
api.nvim_create_user_command("NSSinspect", function(tbl)
    local args = tbl.args
    if tbl.range == 2 then
        nss.inspect(args, true)
    else
        nss.inspect(args, false)
    end
end, {
    nargs = '?',
    range = true,
    complete = function(lead, line, pos)
        local bufnr = api.nvim_get_current_buf()
        local dialect = nss.scripts[bufnr]['dialect']
        local matches = vim.tbl_filter(function(val)
                return vim.startswith(val, lead)
            end, nss.inspect_history[dialect])
            -- end, vim.g.nss_options[dialect].inspect)
        return matches
end,
})



-- Autocommands --------------------------------------------
nss.augroup = api.nvim_create_augroup("NSS", {
    clear = true
})

api.nvim_create_autocmd({"VimLeavePre"}, {
    group = "NSS",
    pattern = "*",
    callback = function()
        nss.delete_tmpfile(0, true)
        nss.close_all_targets()
    end
})

api.nvim_create_autocmd({"FileType"}, {
  group = "NSS",
  pattern = {"r", "rmd"},
  callback = function()
    nss.options()
    nss.register_script('r')
    api.nvim_buf_set_keymap(0, 'x', 'af', [[:<C-U>lua require'nss'.txt_obj_r_function()<CR>]],
        {noremap = true, silent = true})
    api.nvim_buf_set_keymap(0, 'o', 'af', [[:<C-U>lua require'nss'.txt_obj_r_function()<CR>]],
        {noremap = true, silent = true})
  end
})

api.nvim_create_autocmd({"FileType"}, {
  group = "NSS",
  pattern = "python",
  callback = function()
    nss.options()
    nss.register_script('python')
  end
})

api.nvim_create_autocmd({"FileType"}, {
  group = "NSS",
  pattern = "julia",
  callback = function()
    nss.options()
    nss.register_script('julia')
    api.nvim_buf_set_keymap(0, 'x', 'af', [[:<C-U>lua require'nss'.txt_obj_julia_function()<CR>]],
        {noremap = true, silent = true})
    api.nvim_buf_set_keymap(0, 'o', 'af', [[:<C-U>lua require'nss'.txt_obj_julia_function()<CR>]],
        {noremap = true, silent = true})
  end
})


-- Text objects --------------------------------------------
function nss.txt_obj_r_function()
    -- see: https://github.com/kana/vim-textobj-function
    local start_line, end_line, start_end
    local winview = vim.fn.winsaveview()

    if api.nvim_get_current_line() ~= '}' then
        vim.cmd('normal! ][')
    end
    end_line = vim.fn.line('.')

    vim.cmd('normal! %')
    vim.fn.search(')', 'bc')
    vim.cmd('normal! %0')
    start_line = vim.fn.line('.')

    vim.fn.winrestview(winview)
    if 1 < end_line - start_line then
        vim.cmd('normal! ' .. start_line .. 'GV' .. end_line .. 'G')
        start_end = {start_line, end_line}
        return start_end
    end
end

function nss.txt_obj_julia_function()
    -- don't use 'normal!' b/c ][ and % motions are defined in julia plugin
    local start_line, end_line, start_end
    local winview = vim.fn.winsaveview()

    if api.nvim_get_current_line() ~= 'end' then
        vim.cmd('normal ][')
    end
    end_line = vim.fn.line('.')

    vim.cmd('normal %0')
    start_line = vim.fn.line('.')

    vim.fn.winrestview(winview)
    if 1 < end_line - start_line then
        vim.cmd('normal! ' .. start_line .. 'GV' .. end_line .. 'G')
        start_end = {start_line, end_line}
        return start_end
    end
end


-- Options -------------------------------------------------
-- vim.g.nss_options
-- https://zignar.net/2022/11/06/structuring-neovim-lua-plugins/
function nss.options()
    local o = vim.g.nss_options or {}

    o.keys = o.keys or {}
    o.keys.motion = o.keys.motion or 'gl'
    o.keys.visual = o.keys.visual or 'gl'
    o.keys.line   = o.keys.line   or 'gll'

    o.win_cmd = o.win_cmd or 'belowright vnew'

    o.blink = o.blink or {}
    o.blink.higroup = o.blink.higroup or 'IncSearch'
    o.blink.timeout = o.blink.timeout or 150
    o.blink.priority = o.blink.priority or vim.highlight.priorities.user

    o.r = o.r or {}
    o.r.open_cmd = o.r.open_cmd or 'R'
    o.r.exit_cmd = o.r.exit_cmd or 'quit(save = "no")'
    o.r.source_cmd = o.r.source_cmd or [[ source("%s") ]]
    o.r.prompt = o.r.prompt or [[^>]]
    -- o.r.pattern = o.r.pattern or {'*.R', '*.r', '*.rmd', '*.Rmd'}
    o.r.inspect = o.r.inspect or {'head', 'tail'}
    o.r.send_type = o.r.send_type or 'source'
    o.r.highlight_term = o.r.highlight_term or true

    o.julia = o.julia or {}
    o.julia.open_cmd = o.julia.open_cmd or 'julia'
    o.julia.exit_cmd = o.julia.exit_cmd or 'exit()'
    o.julia.source_cmd = o.julia.source_cmd or [[ include("%s") ]]
    o.julia.prompt = o.julia.prompt or [[\(^julia>\|^help?>\|^shell>\)]]
    -- o.julia.pattern = o.julia.pattern or {'*.jl'}
    o.julia.inspect = o.julia.inspect or {'head', 'tail'}
    o.julia.send_type = o.julia.send_type or 'source'

    o.python = o.python or {}
    o.python.open_cmd = o.python.open_cmd or 'python'
    o.python.exit_cmd = o.python.exit_cmd or 'quit()'
    -- o.python.source_cmd = o.python.source_cmd or [[ import "%s" ]]
    o.python.source_cmd = o.python.source_cmd or [[exec(open("%s").read())]]
    o.python.prompt = o.python.prompt or [[^>>>]]
    -- o.python.pattern = o.python.pattern or {'*.py'}
    o.python.inspect = o.python.inspect or {'head', 'tail'}
    o.python.send_type = o.python.send_type or 'source'

    nss.inspect_history = {r = o.r.inspect,
                           julia = o.julia.inspect,
                           python = o.python.inspect}

    vim.g.nss_options = o
end
nss.options()

return nss
