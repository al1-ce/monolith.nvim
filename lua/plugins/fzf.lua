local sysdep = require("utils.sysdep")

local function reverse(tab)
    for i = 1, #tab / 2, 1 do
        tab[i], tab[#tab - i + 1] = tab[#tab - i + 1], tab[i]
    end
    return tab
end

local function deleteProject(paths)
    for _, fpath in ipairs(paths) do
        local choice = vim.fn.confirm("Delete '" .. fpath .. "' from project list?", "&Yes\n&No", 2)

        if choice == 1 then
            require("project_nvim.utils.history").delete_project({ value = fpath })
        end
    end
end

local function fzfProjects()
    require("fzf-lua").fzf_exec(
        reverse(require("project_nvim").get_recent_projects()),
        {
            prompt = " ",
            -- fzf_opts = {['--layout'] = 'reverse'},
            actions = {
                ['default'] = function(selected, opts) require("fzf-lua").files({ cwd = selected[1] }) end,
                ["ctrl-d"] = deleteProject,
                ["ctrl-w"] = function(selected, opts) vim.api.nvim_set_current_dir(selected[1]) end,
            }
        }
    )
end

return {
    -- FZF [ ;ff ;fr ;fp ;fg \ff ... ]
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cond = sysdep({ "fzf" }),
        config = function()
            local fzf = require("fzf-lua")
            -- List of what I usually wouldn't need to see in fzf
            local file_ignores = {
                -- images
                "png", "jpg", "jpeg", "gif", "bmp", "ico", "webp",
                "gpl", "kra", "tiff", "psd", "pdf", "dwg", "svg",
                -- fonts
                "ttf", "woff", "otf",
                -- audio
                "ogg", "mp3", "wav", "aiff", "flac", "oga", "mogg", "raw", "wma",
                -- video
                "mp4", "mkv", "webm", "avi", "amv", "mpg", "mpeg", "mpv",
                "m4v", "svi", "wmv",
                -- binaries, libs and packages assets
                "bin", "exe", "o", "so", "dll", "a", "dylib",
                "rgssad", "pak", "pdb", "bank", "ovl", "dat",
                "mdi", "ad", "dig", "pat", "lev", "mq", "mob",
                "pk3", "wad", "bak", "dbs",
                -- archives
                "zip", "rar", "tar", "gz",
                -- misc
                "rgs", "dat", "ani", "cur", "CurtainsStyle", "CopyComplete", "lst",
            }

            local function get_ignore_patterns()
                local tbl = {}
                for _, v in ipairs(file_ignores) do
                    table.insert(tbl, "%." .. v .. "$")
                    -- table.insert(tbl, "%." .. string.upper(v) .. "$")
                end
                return tbl
            end


            fzf.setup({
                "telescope",
                winopts = {
                    -- border = {"┌", "─", "┐", "│", "┘", "─", "└" , "│" },
                    border = { "┌", " ", "┐", " ", "┘", " ", "└", " " },
                    preview = {
                        -- default = "bat",
                        border = "noborder",
                        vertical = "down:0%",
                        horizontal = "right:60%",
                    }
                },
                fzf_opts = {
                    ['--layout'] = 'reverse',
                },
                fzf_colors = {
                    ["fg"]      = { "fg", "CursorLine" },
                    ["bg"]      = { "bg", "Normal" },
                    ["hl"]      = { "fg", "Comment" },
                    ["fg+"]     = { "fg", "Normal" },
                    ["bg+"]     = { "bg", "Normal" },
                    ["hl+"]     = { "fg", "Statement" },
                    ["info"]    = { "fg", "PreProc" },
                    ["prompt"]  = { "fg", "Conditional" },
                    ["pointer"] = { "fg", "Exception" },
                    ["marker"]  = { "fg", "Keyword" },
                    ["spinner"] = { "fg", "Label" },
                    ["header"]  = { "fg", "Comment" },
                    ["gutter"]  = { "bg", "Normal" },
                },
                -- keymap = {
                --     builtin = {},
                --     fzf = {},
                -- },
                -- actions    = {
                --     files = {
                --         ["default"] = actions.file_edit_or_qf,
                --         ["ctrl-x"]  = actions.file_split,
                --         ["ctrl-v"]  = actions.file_vsplit,
                --         ["ctrl-t"]  = actions.file_tabedit,
                --         ["alt-q"]   = actions.file_sel_to_qf,
                --         ["alt-l"]   = actions.file_sel_to_ll,
                --     },
                --     buffers = {
                --         ["default"] = actions.buf_edit,
                --         ["ctrl-x"]  = actions.buf_split,
                --         ["ctrl-v"]  = actions.buf_vsplit,
                --         ["ctrl-t"]  = actions.buf_tabedit,
                --     }
                -- },
                file_ignore_patterns = get_ignore_patterns(),
                files = {
                    prompt = " ",
                    cwd_prompt = false
                },
                git = {
                    files = { prompt = " " },
                    status = { prompt = " " },
                    commits = { prompt = " " },
                    bcommits = { prompt = " " },
                    branches = { prompt = " " },
                    stash = { prompt = " " },
                },
                grep = {
                    prompt = " ",
                    input_prompt = "󰑑 ",
                },
                args = { prompt = "⌥ " },
                oldfiles = { prompt = " " },
                buffers = { prompt = "﬘ " },
                tabs = { prompt = "󰓩 " },
                lines = { prompt = " " },
                blines = { prompt = " " },
                tags = { prompt = " " },
                btags = { prompt = " " },
                colorschemes = { prompt = " " },
                keymaps = { prompt = " " },
                quickfix = { prompt = " " },
                quickfix_stack = { prompt = " " },
                lsp = {
                    prompt = "󰒋 ",
                    code_actions = { prompt = " " },
                    finder = { prompt = "﯒ " },
                },
                diagnostics = { prompt = " " }
            })
        end,
        event = "VimEnter",
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<cr>",        mode = "n", noremap = true, silent = true, desc = "Opens file picker" },
            { "<leader>fr", "<cmd>FzfLua oldfiles<cr>",     mode = "n", noremap = true, silent = true, desc = "Opens oldfile picker" },
            { "<leader>fg", "<cmd>FzfLua grep_project<cr>", mode = "n", noremap = true, silent = true, desc = "Opens project search" },
            { "<leader>fp", fzfProjects,                    mode = "n", noremap = true, silent = true, desc = "Opens project picker" },
            { "<leader>fm", "<cmd>FzfLua marks<cr>",        mode = "n", noremap = true, silent = true, desc = "Opens marks picker" },
            { "<leader>fk", "<cmd>FzfLua keymaps<cr>",      mode = "n", noremap = true, silent = true, desc = "Shows keymap" },
            { "<leader>f/", "<cmd>FzfLua blines<cr>",       mode = "n", noremap = true, silent = true, desc = "Search in file" },
        },
    },
}