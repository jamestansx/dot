local function write_buf(handle, bufnr)
    local out = {}
    handle:read_start(function(err, data)
        assert(not err, err)
        if data then
            table.insert(out, data)
        else
            handle:close()
            vim.schedule(function()
                out = vim.split(table.concat(out), "\n")
                vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, out)
            end)
        end
    end)
end

local function shell_cmd(bufnr, cmd, input)
    local stdin, stdout, stderr = vim.uv.new_pipe(), vim.uv.new_pipe(), vim.uv.new_pipe()

    vim.uv.spawn("sh", {
        args = { "-c", cmd:sub(2) },
        stdio = { stdin, stdout, stderr },
    })

    stdin:write(input or "", function()
        stdin:shutdown(function()
            if stdin then
                stdin:close()
            end
        end)
    end)

    write_buf(stdout, bufnr)
    write_buf(stderr, bufnr)
end

local function create_buf()
    local bufnr = vim.api.nvim_create_buf(false, true)
    assert(bufnr ~= 0, "Could not create a new buffer")
    vim.api.nvim_set_option_value("ft", "redir", { buf = bufnr })

    return bufnr
end

local function open_win(bufnr, vertical)
    return vim.api.nvim_open_win(bufnr, false, {
        vertical = vertical or false,
        win = 0,
    })
end

local function redir(kwargs)
    local cmd = kwargs.args
    local stderr = kwargs.bang
    local vertical = kwargs.smods.vertical

    local bufnr = create_buf()
    local winid = open_win(bufnr, vertical)

    if cmd:sub(1, 1) == "!" then
        local input
        if kwargs.range ~= 0 then
            local l1 = kwargs.line1 - 1
            local l2 = kwargs.line2
            input = vim.api.nvim_buf_get_lines(0, l1, l2, true)
            input = table.concat(input, "\n")
        end
        shell_cmd(bufnr, cmd, input)
    else
        local output = vim.fn.execute(cmd)
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, vim.fn.split(output, "\n"))
    end

    vim.api.nvim_set_current_win(winid)
end

vim.api.nvim_create_user_command("Redir", redir, {
    nargs = "+",
    complete = "command",
    bang = true,
    range = true,
})

vim.api.nvim_create_user_command("Mess", function()
    vim.cmd("Redir messages")
end, { bar = true })
