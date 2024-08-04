vim.wo.colorcolumn = ''
vim.bo.errorformat = "%f|%l col %c| %m,%f|%l col %c-%k| %m,%f|%l col %c-%k %t%*[^:]| %m"

local grp = vim.api.nvim_create_augroup("qf", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = grp,
    buffer = 0,
    nested = true,
    callback = function()
        if vim.fn.winnr("$") < 2 then
            vim.cmd([[silent quit]])
        end
    end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = grp,
    buffer = 0,
    once = true,
    command = [[setlocal modifiable]],
})

if vim.g.loaded_cfilter == nil then
    vim.cmd("packadd cfilter")
    vim.g.loaded_cfilter = 1
end

vim.keymap.set("n", "q", "<CMD>quit!<CR>", { buffer = 0, nowait = true })
vim.keymap.set("n", "<C-S>", "<CMD>cgetbuffer|cclose|copen<CR>", { buffer = 0 })
