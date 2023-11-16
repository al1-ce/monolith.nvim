require("noice").setup({
    cmdline = {
        enabled = true,     -- enables the Noice cmdline UI
        view = "cmdline", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        opts = {},          -- global options for the cmdline. See section on views
        format = {
            -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
            -- view: (default is cmdline view)
            -- opts: any options passed to the view
            -- icon_hl_group: optional hl_group for the icon
            -- title: set to anything or empty string to hide
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            checkhealth = { pattern = "^:%s*check?h?e?a?l?t?h?%s+", icon = "🤍" },
            telescope = { pattern = "^:%s*Tele?s?c?o?p?e?%s+", icon = "" },
            lazy = { pattern = "^:%s*Lazy%s+", icon = "🥡" },
            lspsaga = { pattern = "^:%s*Lspsaga%s+", icon = "" },
            input = {}, -- Used by input()
        },
    },
    messages = {
        enabled = true,          -- enables the Noice messages UI
        view = "notify",         -- default view for messages
        view_error = "notify",   -- view for errors
        view_warn = "notify",    -- view for warnings
        view_history = "messages", -- view for :messages
        view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
    },
    popupmenu = {
        enabled = false, -- enables the Noice popupmenu UI
        backend = "nui", -- backend to use to show regular cmdline completions
        kind_icons = {}, -- set to `false` to disable icons
    },
    redirect = {
        view = "popup",
        filter = { event = "msg_show" },
    },
    commands = {
        history = {
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
                any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = { "" } },
                    { event = "lsp",      kind = "message" },
                },
            },
        },
        last = {
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
                any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = { "" } },
                    { event = "lsp",      kind = "message" },
                },
            },
            filter_opts = { count = 1 },
        },
        errors = {
            view = "split",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
        },
    },
    notify = {enabled = true,view = "notify",},
    lsp = {
        progress = {enabled = false},
        override = {},
        hover = {enabled = false},
        signature = {enabled = false},
        message = {enabled = true,view = "notify",opts = {},},
        documentation = {},
    },
    markdown = {
        hover = {},
        highlights = {
            ["|%S-|"] = "@text.reference",
            ["@%S+"] = "@parameter",
            ["^%s*(Parameters:)"] = "@text.title",
            ["^%s*(Return:)"] = "@text.title",
            ["^%s*(See also:)"] = "@text.title",
            ["{%S-}"] = "@parameter",
        },
    },
    health = {checker = true},
    smart_move = {enabled = false},
    presets = {
        bottom_search = false,     -- use a classic bottom cmdline for search
        command_palette = false,   -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,        -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,    -- add a border to hover docs and signature help
    },
    throttle = 1000 / 30,          -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
    views = {}, ---@see section on views
    routes = {}, --- @see section on routes
    status = {}, --- @see section on statusline components
    format = {}, --- @see section on formatting
})

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader><leader>", "<cmd>Noice dismiss<cr>", opts)

