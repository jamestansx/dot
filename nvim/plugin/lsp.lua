local function lsp_client_complete()
    return vim.tbl_map(function(t)
        return t.name
    end, vim.lsp.get_clients())
end

local function start_client(client, bufs)
    local client_id = vim.lsp.start_client(client.config)
    if client_id then
        for buf in pairs(bufs) do
            vim.lsp.buf_attach_client(buf, client_id)
        end
    end
end

vim.api.nvim_create_user_command("LspRestart", function(kwargs)
    local bufnr = vim.api.nvim_get_current_buf()
    local name = kwargs.fargs[1]
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = name })

    local detached_clients = {}
    for _, client in ipairs(clients) do
        client.stop(kwargs.bang)
        detached_clients[client.name] = {
            client,
            vim.deepcopy(client.attached_buffers),
        }
    end

    local timer = assert(vim.uv.new_timer())
    timer:start(500, 100, vim.schedule_wrap(function()
        for name, tuple in pairs(detached_clients) do
            local client, attached_bufs = unpack(tuple)
            if client.is_stopped() then
                start_client(client, attached_bufs)
                detached_clients[name] = nil
            end
        end

        if next(detached_clients) == nil and not timer:is_closing() then
            timer:close()
        end
    end))
end, { nargs = "*", complete = lsp_client_complete, bang = true })

vim.api.nvim_create_user_command("LspStop", function(kwargs)
    local bufnr = vim.api.nvim_get_current_buf()
    local name = kwargs.fargs[1]
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = name })

    for _, client in ipairs(clients) do
        client.stop(kwargs.bang)
    end
end, { nargs = "*", complete = lsp_client_complete, bang = true })

vim.api.nvim_create_user_command("LspLog", function()
    local path = vim.lsp.get_log_path()
    vim.cmd.split(path)
end, {})
