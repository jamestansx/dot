vim.loader.enable()

-- TODO: packadd cfilter

_G.create_autocmd = function(ev, opts)
    if opts.group and vim.fn.exists("#" .. opts.group) == 0 then
        vim.api.nvim_create_augroup(opts.group, { clear = true })
    end
    vim.api.nvim_create_autocmd(ev, opts)
end

-- disable remote plugin providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('', "<Space>", "<Nop>")

-- ui
vim.opt.title = true
vim.opt.titlestring = [[%{getcwd().' ('.getpid().')'}]]
vim.opt.colorcolumn = "+1"
vim.opt.shortmess:append("IAca")

-- editor
vim.opt.autowriteall = true
vim.opt.jumpoptions = "stack,view"
vim.opt.isfname:append("@-@")
vim.opt.foldlevelstart = 99
vim.opt.undofile = true
vim.opt.virtualedit = "block"
vim.opt.mousemodel = "extend" -- xterm mouse
vim.opt.shada:append({
    "r/tmp/",
    "rfugitive", "rterm:", "rhealth",
})
---
vim.opt.exrc = true
vim.opt.modelines = 1
---

-- statuscolumn
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- statusline
vim.opt.laststatus = 3
vim.opt.cmdheight = 2
vim.opt.showmode = false

-- redraw
vim.opt.redrawtime = 1000
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10
vim.opt.updatetime = 1000

-- indent
vim.opt.smartindent = true
vim.opt.shiftround = true

-- completion
vim.opt.pumblend = 10
vim.opt.pumheight = 5
vim.opt.confirm = true
vim.opt.completeopt = "menuone,noinsert,noselect,popup"

-- wrap
vim.opt.linebreak = true
vim.opt.smoothscroll = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪"

-- window
vim.opt.winblend = 10
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- list
vim.opt.list = true
vim.opt.listchars = {
    trail = "·",
    tab = "  ⇥",
    nbsp = "⦸",
    extends = "→",
    precedes = "←",
}
vim.opt.fillchars = {
    fold = " ",
    foldopen = "▽",
    foldsep = " ",
    foldclose = "▷",
    -- msgsep = "⎻", -- U+23BB
}

-- search and replace
vim.opt.hlsearch = false
vim.opt.ignorecase = true -- \C to disable case-insensitive
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- wildmenu
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildoptions = { "fuzzy", "tagfile" } -- disable popup
vim.opt.wildignorecase = true
vim.opt.wildcharm = (""):byte()
vim.opt.wildignore:append({
    "*.lock", "*cache", "*.swp",
    "*.pyc", "*.pycache", "*/__pycache__/*",
    "*/node_modules/*", "*.min.js",
    "*.o", "*.obj", "*~",
})

-- diff
vim.opt.diffopt:append({
    "iwhite",
    "indent-heuristic",
    "algorithm:histogram",
    "linematch:60",
})

-- https://vi.stackexchange.com/a/9366/37072
_G.create_autocmd("FileType", {
    group = "FormatOption",
    command = [[set fo-=o]],
})

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --no-heading --smart-case --vimgrep"
    vim.opt.grepformat = { "%f:%l:%c:%m", "%f:%l:%m" }
end

-- diagnostic
vim.diagnostic.config({
    severity_sort = true,
})

-- center search result
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
vim.keymap.set("n", "g*", "g*zz")

-- no arrow keys
vim.keymap.set('', "<Up>", "<Nop>")
vim.keymap.set('', "<Down>", "<Nop>")
vim.keymap.set('', "<Left>", "<Nop>")
vim.keymap.set('', "<Right>", "<Nop>")

-- home row
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "gJ", "mzgJ`z")

-- https://github.com/mhinz/vim-galore#saner-command-line-history
vim.keymap.set("c", "<C-N>", [[wildmenumode() == 1 ? "<C-N>" : "\<Down\>"]], { expr = true })
vim.keymap.set("c", "<C-P>", [[wildmenumode() == 1 ? "<C-P>" : "\<Up\>"]], { expr = true })

-- smart jk
vim.keymap.set({"n", "x"}, "j", [[v:count || mode(1)[0:1] == "no" ? "j" : "gj"]], { expr = true })
vim.keymap.set({"n", "x"}, "k", [[v:count || mode(1)[0:1] == "no" ? "k" : "gk"]], { expr = true })

-- unimpaired style
vim.keymap.set("n", "[<Space>", [[<CMD>put!=repeat(nr2char(10), v:count1)<BAR>']+1<CR>]])
vim.keymap.set("n", "[<Space>", [[<CMD>put =repeat(nr2char(10), v:count1)<BAR>'[-1<CR>]])

-- TODO: remove once v0.11 has landed
vim.keymap.set("n", "[Q", "<Cmd>cfirst<CR>")
vim.keymap.set("n", "]Q", "<Cmd>clast<CR>")
vim.keymap.set("n", "[q", [["\<Cmd\>" . v:count1 . "cprev" . "\<CR\>" . "zz"]], { expr = true })
vim.keymap.set("n", "]q", [["\<Cmd\>" . v:count1 . "cnext" . "\<CR\>" . "zz"]], { expr = true })
vim.keymap.set("n", "[A", "<Cmd>first<CR>")
vim.keymap.set("n", "]A", "<Cmd>last<CR>")
vim.keymap.set("n", "[a", [["\<Cmd\>" . v:count1 . "prev" . "\<CR\>"]], { expr = true })
vim.keymap.set("n", "]a", [["\<Cmd\>" . v:count1 . "next" . "\<CR\>"]], { expr = true })
vim.keymap.set({ "i", "s" }, "<Tab>", function()
    return vim.snippet.active({ direction = 1 }) and "<CMD>lua vim.snippet.jump(1)<CR>" or "<Tab>"
end, { expr = true, silent = true })
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    return vim.snippet.active({ direction = -1 }) and "<CMD>lua vim.snippet.jump(-1)<CR>" or "<S-Tab>"
end, { expr = true, silent = true })

-- TODO:
-- keymap with 'yo<key>'
-- nnoremap g<Space> :Git<Space>
-- nnoremap g!       :Git!<Space>
-- nnoremap g<CR>    <CMD>Git<CR>
-- nnoremap gq       mzgggqG`z

_G.create_autocmd("TextYankPost", {
    group = "JamesTan",
    callback = function()
        vim.highlight.on_yank({ timeout = 50 })
    end,
})

_G.create_autocmd("BufNewFile", {
    group = "JamesTan",
    callback = function()
        _G.create_autocmd("BufWritePre", {
            group = "Mkdir",
            buffer = 0,
            once = true,
            callback = function(args)
                -- ignore URL pattern
                if not args.match:match("^%w+://") then
                    local file = vim.uv.fs_realpath(args.match) or args.match
                    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
                end
            end,
        })
    end,
})

_G.create_autocmd("BufRead", {
    group = "JamesTan",
    callback = function()
        local exclude = { "gitcommit", "gitrebase", "help" }
        if vim.tbl_contains(exclude, vim.bo.ft) then
            return
        end

        local mark = vim.api.nvim_buf_get_mark(0, '"')[1]
        if mark > 0 and mark <= vim.api.nvim_buf_line_count(0) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

_G.create_autocmd("BufWritePre", {
    group = "JamesTan",
    pattern = {
        "/tmp/*",
        "gitcommit",
        "gitrebase",
    },
    command = [[setlocal noundofile]],
})

-- lazy.nvim
local lazypath = string.format("%s/lazy/lazy.nvim", vim.fn.stdpath("data"))
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local spec = {}

if package.loaded["lazy"] == nil then
    require("lazy").setup({
        spec = spec,
        install = { colorscheme = { "kanagawa-dragon", "retrobox" } },
        diff = { cmd = "diffview.nvim" },
        checker = { enabled = false },
        change_detection = { notify = false },
        performance = {
            rtp = {
                disabled_plugins = {
                    "tutor",
                    "rplugin",
                    "gzip",
                    "tarPlugin",
                    "zipPlugin",
                    "spellfile",
                },
            },
        },
    })
end
