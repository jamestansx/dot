local attached_repo = {}
local group = vim.api.nvim_create_augroup("GitAttached", { clear = true })

local function fetch_info(cwd)
    local stdout = assert(vim.uv.new_pipe())
    vim.uv.spawn("git", {
        args = {
            "rev-parse",
            "--show-toplevel",
            "--absolute-git-dir",
            "--abbrev-ref",
            "HEAD",
        },
        stdio = { nil, stdout, nil },
        cwd = vim.fn.fnamemodify(cwd, ":p:h"),
    })
    return stdout
end

local function table_fast_remove(t, remove_val)
    local j, n = 1, #t
    for i = 1, n do
        if t[i] == remove_val then
            t[i] = nil
        else
            if i ~= j then
                t[j] = t[i]
                t[i] = nil
            end
            j = j + 1
        end
    end

    return t
end

local function detach(bufnr)
    vim.api.nvim_create_autocmd({ "BufHidden", "BufUnload" }, {
        buffer = bufnr,
        group = group,
        callback = function(ev)
            local dir = vim.b[ev.buf].git_dir
            if not dir or not attached_repo[dir] then
                return
            end

            attached_repo[dir].attached_buffers = table_fast_remove(
                attached_repo[dir].attached_buffers,
                ev.buf
            )

            if #attached_repo[dir].attached_buffers == 0 then
                local repo = attached_repo[dir]
                repo.fs:close()
                if repo.timer then
                    repo.timer:close()
                end
                attached_repo[dir] = nil
            end
        end,
    })
end

local function fs_attach(dir)
    local repo = attached_repo[dir]
    repo.fs:start(dir, {}, function(err, _, _)
        assert(not err, err)

        if attached_repo[dir].timer == nil then
            attached_repo[dir].timer = assert(vim.uv.new_timer())
        end

        attached_repo[dir].timer:start(200, 0, function()
            attached_repo[dir].timer:stop()
            attached_repo[dir].timer = nil

            local out = fetch_info(repo.cwd)
            out:read_start(function(err, data)
                assert(not err, err)
                if data == nil then
                    return
                end

                local branch = vim.split(data, "\n")[3]
                for _, v in ipairs(repo.attached_buffers) do
                    vim.b[v].git_branch = branch
                end

                vim.schedule_wrap(vim.api.nvim_exec_autocmds)("User", {
                    pattern = "GitUpdate",
                })
            end)
        end)
    end)
end

vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(ev)
        local out = fetch_info(ev.match)

        out:read_start(function(err, data)
            assert(not err, err)
            if data == nil then
                return
            end

            local root, dir, branch = unpack(vim.split(data, "\n"))

            vim.b[ev.buf].git_dir = dir
            vim.b[ev.buf].git_branch = branch

            vim.schedule(function()
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "GitUpdate",
                })
            end)

            vim.schedule_wrap(detach)(ev.buf)

            if attached_repo[dir] == nil then
                attached_repo[dir] = {
                    cwd = root,
                    attached_buffers = { ev.buf },
                    fs = assert(vim.uv.new_fs_event()),
                }
            elseif not vim.list_contains(attached_repo[dir].attached_buffers, ev.buf) then
                vim.schedule(function()
                    table.insert(attached_repo[dir].attached_buffers, ev.buf)
                end)
                return
            end

            fs_attach(dir)
        end)
    end,
})

vim.api.nvim_create_autocmd("VimSuspend", {
    group = group,
    callback = function()
        for k, v in pairs(attached_repo) do
            v.fs:stop()
        end
    end,
})
vim.api.nvim_create_autocmd("VimResume", {
    group = group,
    callback = function()
        for k, v in pairs(attached_repo) do
            fs_attach(k)
        end
    end,
})
