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
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3

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
    group = "JamesTan",
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
-- black hole mapping
-- system clipboard yank/paste

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

        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
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

-- load shada manually saves about 10ms
-- TODO: test if doing this will cause any problem
local shada = vim.opt.shada
vim.opt.shada = ''
_G.create_autocmd("User", {
    group = "JamesTan",
    pattern = "VeryLazy",
    callback = function()
        vim.opt.shada = shada
        pcall(vim.cmd.rshada, { bang = true })
    end,
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

local spec = {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("kanagawa").setup({
                theme = "dragon",
                background = { dark = "dragon" },
                compile = true,
                transparent = true,

                commentStyle = { italic = false },
                keywordStyle = { italic = false },
                statmentStyle = { bold = false },

                overrides = function(C)
                    local T = C.theme
                    local P = C.palette

                    return {
                        -- dark completion popup menu
                        Pmenu = {
                            fg = T.ui.shade0,
                            bg = T.ui.bg_p1,
                            blend = vim.o.pumblend,
                        },
                        PmenuSel = { fg = "NONE", bg = T.ui.bg_p2 },
                        PmenuSbar = { bg = T.ui.bg_m1 },
                        PmenuThumb = { bg = T.ui.bg_p2 },

                        Boolean = { bold = false },
                    }
                end,
            })

            vim.cmd.colorscheme("kanagawa")
        end,
    },
    {
        "andymass/vim-matchup",
        init = function()
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
            vim.g.matchup_matchparen_deferred = 1
        end,
    },
    {
        "justinmk/vim-dirvish",
        init = function()
            vim.g.dirvish_mode = [[:sort /^.*[\/]/]]
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        cmd = { "CmpStatus" },
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                completion = {
                    completeopt = vim.o.completeopt,
                    keyword_length = 2,
                },
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-E>"] = cmp.mapping.abort(),
                    ["<C-Y>"] = cmp.mapping.confirm({ select = true }),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<C-F>"] = cmp.mapping.scroll_docs(5),
                    ["<C-B>"] = cmp.mapping.scroll_docs(-5),
                }),
                sources = cmp.config.sources({
                    { name = "path" },
                    {
                        name = "buffer",
                        keyword_length = 5,
                        option = {
                            get_bufnrs = function()
                                local bufs = {}
                                local max_index_filesize = 1048576 -- 1MB
                                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                                    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
                                    if vim.api.nvim_buf_is_loaded(buf)
                                        and buftype ~= "nofile"
                                        and buftype ~= "prompt" then
                                        local loc = vim.api.nvim_buf_line_count(buf)
                                        local offset = vim.api.nvim_buf_get_offset(buf, loc)
                                        if offset <= max_index_filesize then
                                            table.insert(bufs, buf)
                                        end
                                    end
                                end

                                return bufs
                            end,
                        },
                    },
                }),
                sorting = {
                    priority_weight = 3,
                    comparators = {
                        function(...) return require("cmp_buffer"):compare_locality(...) end,
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        -- https://github.com/lukas-reineke/cmp-under-comparator
                        function(entry1, entry2)
                            local _, entry1_under = entry1.completion_item.label:find("^_+")
                            local _, entry2_under = entry2.completion_item.label:find("^_+")
                            entry1_under = entry1_under or 0
                            entry2_under = entry2_under or 0
                            if entry1_under > entry2_under then
                                return false
                            elseif entry1_under < entry2_under then
                                return true
                            end
                        end,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                experimental = { ghost_text = true },
            })
        end,
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = {
            use_icons = false,
            enhanced_diff_hl = true,
            show_help_hints = false,
            view = {
                merge_tool = { layput = "diff3_mixed" },
                file_panel = { listing_style = "list" },
            },
        },
    },
    {
        "mbbill/undotree",
        keys = {
            { "you", vim.cmd.UndotreeToggle, mode = "n" },
        },
        init = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_ShortIndicators = 1
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_HelpLine = 0
        end,
    },
}

if package.loaded["lazy"] == nil then
    vim.opt.rtp:prepend(lazypath)
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
                    "matchit",
                    "matchparen",
                    "netrwPlugin",
                },
            },
        },
    })
end
