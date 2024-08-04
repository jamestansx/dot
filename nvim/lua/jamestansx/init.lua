-- delay notify until fidget is loaded
if true then
    local notifs = {}
    local orig = vim.notify
    vim.notify = function(...)
        table.insert(notifs, {...})
    end

    local timer = assert(vim.uv.new_timer())
    local check = assert(vim.uv.new_check())
    local replay = function()
        timer:close()
        check:close()
        vim.schedule_wrap(function()
            for _, notif in ipairs(notifs) do
                vim.notify(unpack(notif))
            end
        end)()
    end

    check:start(function()
        if package.loaded["fidget"] then
            replay()
        end
    end)
    timer:start(100, 0, function()
        if not package.loaded["fidget"] then
            vim.notify = orig
        end
        replay()
    end)
end

-- local augroup for init.lua
local grp = vim.api.nvim_create_augroup("init.lua", { clear = true })

local function lspconfig(name, config)
    if config.disable then
        return
    end

    config.name = name
    vim.api.nvim_create_autocmd("FileType", {
        group = grp,
        pattern = config.filetypes,
        callback = function(args)
            if vim.bo[args.buf].buftype == "nofile" then
                return
            end

            config.capabilities = vim.lsp.protocol.make_client_capabilities()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            config.capabilities = vim.tbl_deep_extend("force", config.capabilities, capabilities)

            config.markers = config.markers or {}
            table.insert(config.markers, ".git")
            config.root_dir = vim.fs.root(args.buf, config.markers)

            vim.lsp.start(config)
            vim.lsp.log.set_format_func(vim.inspect)
        end,
    })
end

-- disable remote plugin providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ui
-- vim.opt.title = true
-- vim.opt.titlestring = [[%{getcwd().' ('.getpid().')'}]]
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
vim.opt.exrc = true
vim.opt.modelines = 1

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
vim.opt.completeopt = "menuone,noinsert,noselect,popup,fuzzy"

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
vim.api.nvim_create_autocmd("FileType", {
    group = grp,
    command = [[set fo-=o]],
})

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --no-heading --smart-case --vimgrep"
    vim.opt.grepformat = { "%f:%l:%c:%m", "%f:%l:%m" }
end

-- diagnostic
vim.diagnostic.config({
    severity_sort = true,
    jump = {
        float = true,
    },
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
vim.keymap.set({ "n", "x", "o" }, "H", "^")
vim.keymap.set({ "n", "x", "o" }, "L", "$")

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
vim.keymap.set("n", "]<Space>", [[<CMD>put =repeat(nr2char(10), v:count1)<BAR>'[-1<CR>]])

-- NOTE: wait for https://github.com/neovim/neovim/pull/28525 to be merged
vim.keymap.set("n", "[Q", "<Cmd>cfirst<CR>")
vim.keymap.set("n", "]Q", "<Cmd>clast<CR>")
vim.keymap.set("n", "[q", [["\<Cmd\>".v:count1."cprev"."\<CR\>"."zz"]], { expr = true })
vim.keymap.set("n", "]q", [["\<Cmd\>".v:count1."cnext"."\<CR\>"."zz"]], { expr = true })
vim.keymap.set("n", "[A", "<Cmd>first<CR>")
vim.keymap.set("n", "]A", "<Cmd>last<CR>")
vim.keymap.set("n", "[a", [["\<Cmd\>".v:count1."prev"."\<CR\>"]], { expr = true })
vim.keymap.set("n", "]a", [["\<Cmd\>".v:count1."next"."\<CR\>"]], { expr = true })

-- mini.pick
vim.keymap.set("n", "<leader>f", function()
    local fd = "fd --color=never --type file --hidden --follow --exclude .git"
    local base = vim.fn.expand("%:.")
    base = vim.fn.empty(base) == 0 and vim.fn.shellescape(base) or '.'
    local cmd = string.format("%s | proximity-sort %s", fd, base)

    MiniPick.builtin.cli({ command = { "sh", "-c", cmd } }, { source = { name = "Files" } })
end)
vim.keymap.set("n", "<leader>g", "<Cmd>Pick grep_live<CR>")
vim.keymap.set("n", "yop", "<Cmd>Pick resume<CR>")

vim.api.nvim_create_autocmd("TextYankPost", {
    group = grp,
    callback = function()
        vim.highlight.on_yank({ timeout = 50 })
    end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
    group = grp,
    callback = function()
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = "Mkdir",
            buffer = 0,
            once = true,
            callback = function(args)
                -- ignore uri pattern
                if not args.match:match("^%w+://") then
                    local file = vim.uv.fs_realpath(args.match) or args.match
                    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
                end
            end,
        })
    end,
})

vim.api.nvim_create_autocmd("BufRead", {
    group = grp,
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

vim.api.nvim_create_autocmd("BufWritePre", {
    group = grp,
    pattern = {
        "/tmp/*",
        "gitcommit",
        "gitrebase",
    },
    command = [[setlocal noundofile]],
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = grp,
    callback = function(args)
        local buf = args.buf
        local handlers = vim.lsp.handlers

        handlers["textDocument/signatureHelp"] = vim.lsp.with(handlers.signature_help, {
            anchor_bias = "above",
        })
        handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, {
            anchor_bias = "above",
        })
    end,
})

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
        event = "BufReadPost",
        init = function()
            -- XXX: enable both 'popup' and 'deferred' would cause offscreen not able to
            -- show up properly on split windows.
            -- see https://github.com/andymass/vim-matchup/issues/325#issuecomment-1973466079
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
            "hrsh7th/cmp-nvim-lsp",
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
                    { name = "nvim_lsp" },
                },{
                    { name = "path" },
                    {
                        name = "buffer",
                        keyword_length = 5,
                        option = {
                            get_bufnrs = function()
                                local bufs = {}
                                local max_index_filesize = 1048576 -- 1MB

                                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                                    local buftype = vim.api.nvim_get_option_value("buftype", {
                                        buf = buf,
                                    })
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
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G" },
        keys = {
            { "g<Space>", ":Git<Space>", mode = "n" },
            { "g!", ":Git!<Space>", mode = "n" },
            { "g<CR>", "<CMD>Git<CR>", mode = "n" },
        },
    },
    { "nvim-lua/plenary.nvim", lazy = true },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        keys = function()
            local harpoon = require("harpoon")
            local list = harpoon:list()

            return {
                { "<leader>a", function() list:add() end, mode = "n" },
                { "yoh", function()
                    harpoon.ui:toggle_quick_menu(list, {
                        border = "solid",
                        title_pos = "center",
                        ui_fallback_width = 30,
                        ui_width_ratio = 0.4,
                        ui_max_width = 69,
                    })
                end, mode = "n" },

                { "<leader>h", function() list:select(1) end, mode = "n" },
                { "<leader>j", function() list:select(2) end, mode = "n" },
                { "<leader>k", function() list:select(3) end, mode = "n" },
                { "<leader>l", function() list:select(4) end, mode = "n" },

                { "<leader>H", function() list:replace_at(1) end, mode = "n" },
                { "<leader>J", function() list:replace_at(2) end, mode = "n" },
                { "<leader>K", function() list:replace_at(3) end, mode = "n" },
                { "<leader>L", function() list:replace_at(4) end, mode = "n" },
            }
        end,
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({
                settings = {
                    save_on_toggle = true,
                },
            })

            harpoon:extend({
                UI_CREATE = function(cx)
                    vim.api.nvim_set_option_value("number", false, { win = cx.win_id })
                end,
            })
        end,
    },
    {
        "echasnovski/mini.pick",
        version = "*",
        config = function()
            require("mini.pick").setup({
                mappings = {
                    toggle_info = "<C-K>",
                },
                options = {
                    content_from_bottom = true,
                    use_cache = true,
                },
            })

            vim.ui.select = MiniPick.ui_select
        end,
    },
    {
        "ggandor/leap.nvim",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            local leap = require("leap")

            leap.create_default_mappings()
            vim.keymap.set({ "n", "o" }, "gS", require("leap.remote").action)

            leap.opts.special_keys = {
                next_target = "<Enter>",
                prev_target = "<S-Enter>",
                next_group = "<Space>",
                prev_group = "<S-Space>",
            }
        end,
    },
    {
        "echasnovski/mini.align",
        version = "*",
        keys = { "gl", "gL" },
        config = function()
            require("mini.align").setup({
                mappings = {
                    start = "gl",
                    start_with_preview = "gL",
                },
            })
        end,
    },
    {
        "j-hui/fidget.nvim",
        event = "UIEnter",
        opts = {
            progress = {
                display = {
                    render_limit = 7,
                },
            },
            notification = {
                history_size = 32,
                -- TODO: do I want to replace builtin vim.notify with fidget?
                override_vim_notify = true,
                redirect = false,
                window = {
                    winblend = 0,
                    align = "bottom",
                },
            },
        },
    },
}

-- startup config
if package.loaded["lazy"] == nil then
    local lazypath = string.format("%s/lazy/lazy.nvim", vim.fn.stdpath("data"))
    if not vim.uv.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "--branch=stable",
            "https://github.com/folke/lazy.nvim.git",
            lazypath,
        }):wait()
    end
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

    -- load shada manually saves about 10ms
    local shada = vim.opt.shada
    vim.opt.shada = ''
    vim.api.nvim_create_autocmd("User", {
        group = grp,
        pattern = "VeryLazy",
        once = true,
        callback = function()
            vim.opt.shada = shada
            pcall(vim.cmd.rshada, { bang = true })
        end,
    })
end

-- TODO:
-- the basic neovim setup is done, left the following stuffs to be done.
--
-- keymap:
-- - formatting keymap
--   nnoremap gq mzgggqG`z
--   or require("conform").format()
--   or going with autocmd with conform.nvim
-- - black hole mapping (delete)
-- - system clipboard yank/paste
--
-- plugins:
-- - indent-blankline
-- - conform (formatter)
-- - nvim-lint (linter)
-- - neorg
-- - statusline
-- - db (dadbod)
-- nice to have:
-- - dap.nvim
-- - search n replace (spectre.nvim/ssr.nvim)
-- - moveline
-- - firenvim
