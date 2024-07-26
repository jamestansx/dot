local function eat_space(map)
    local eatspace = "(nr2char(getchar(0)) =~ '\\s') ? '' : nr2char(getchar(0))"
    return string.format("%s<C-R>=%s<CR>", map, eatspace)
end

vim.keymap.set("ca", "e", eat_space("e %"), { buffer = 0 })
vim.keymap.set("ca", "mkdir", eat_space("!mkdir -p %"), { buffer = 0 })
