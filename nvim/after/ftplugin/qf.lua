vim.wo.colorcolumn = ''

vim.keymap.set("n", "q", ":q!<CR>", {
    buffer = 0,
    nowait = true,
})

_G.create_autocmd("BufEnter", {
    group = "JamesTan",
    buffer = 0,
    nested = true,
    callback = function()
        if vim.fn.winnr("$") < 2 then
            vim.cmd([[silent quit]])
        end
    end,
})

_G.create_autocmd("BufWinEnter", {
    group = "JamesTan",
    buffer = 0,
    once = true,
    command = [[setlocal modifiable]],
})

if vim.g.loaded_cfilter == nil then
    vim.cmd("packadd cfilter")
    vim.g.loaded_cfilter = 1
end

vim.bo.errorformat = "%f|%l col %c| %m,%f|%l col %c-%k| %m,%f|%l col %c-%k %t%*[^:]| %m"
vim.keymap.set("n", "<C-S>", "<CMD>cgetbuffer|cclose|copen<CR>", { buffer = 0 })
