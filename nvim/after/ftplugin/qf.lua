vim.wo.colorcolumn = ""

vim.keymap.set("n", "q", "<C-W>c", { buffer = 0 })
vim.keymap.set("n", "D", function()
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    local qflist = vim.fn.getqflist()

    for i = 0, vim.v.count1 - 1 do
        table.remove(qflist, line)
    end
    vim.fn.setqflist(qflist, "r")

    vim.api.nvim_win_set_cursor(0, { line, col })
    return [[\<Nop\>]]
end, { buffer = 0, expr = true })
vim.keymap.set("x", "D", function()
    local _, visline, viscol, _ = unpack(vim.fn.getpos("v"))
    local _, curline, curcol, _ = unpack(vim.fn.getpos("."))
    local qflist = vim.fn.getqflist()

    local startpos = visline > curline
    local l = startpos and curline or visline
    local c = startpos and curcol or viscol
    local total = math.abs(visline - curline)
    for _ = 0, total do
        table.remove(qflist, l)
    end
    vim.fn.setqflist(qflist, "r")

    vim.fn.cursor(l, c)
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
    vim.api.nvim_feedkeys(esc, "n", true)
end, { buffer = 0 })

_G.create_autocmd("BufEnter", {
    group = "JamesTan",
    buffer = 0,
    callback = function()
        if vim.fn.winnr("$") < 2 then
            vim.cmd([[silent quit]])
        end
    end,
})
