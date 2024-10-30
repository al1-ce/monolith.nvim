local sysdep = import "utils.sysdep" .sysdep
local borders = import "var.borders"

return {
    -- {
    --     "NoahTheDuke/vim-just",
    --     event = { "BufReadPre", "BufNewFile" },
    --     ft = { "\\cjustfile", "*.just", ".justfile", "justfile" },
    -- },
    {
        "IndianBoy42/tree-sitter-just",
        dependencies = { "nvim-treesitter/nvim-treesitter" }
    },
    {
        "al1-ce/just.nvim",
        -- dir = "/g/al1-ce/just.nvim",
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'rcarriga/nvim-notify',
            'j-hui/fidget.nvim',
            "al1-ce/jsfunc.nvim",
        },
        event = "VimEnter",
        cond = sysdep({ "aplay" }),
        opts = {
            fidget_message_limit = 32,
            play_sound = true,
            open_qf_on_error = true,
            telescope_borders = {
                prompt = borders.telescope_top,
                results = borders.telescope_bottom,
                preview = borders.telescope
            }
        },
        keys = {
            { "<leader>bd", "<cmd>Just default<cr>", mode = "n", noremap = true, silent = true, desc = "Run default task" },
            { "<leader>bD", "<cmd>Just debug<cr>",   mode = "n", noremap = true, silent = true, desc = "Run debug task" },
            { "<leader>bb", "<cmd>Just build<cr>",   mode = "n", noremap = true, silent = true, desc = "Run build task" },
            { "<leader>br", "<cmd>Just run<cr>",     mode = "n", noremap = true, silent = true, desc = "Run run task" },
            { "<leader>bR", "<cmd>Just release<cr>", mode = "n", noremap = true, silent = true, desc = "Run release task" },
            { "<leader>bf", "<cmd>Just file<cr>",    mode = "n", noremap = true, silent = true, desc = "Run file task" },
            { "<leader>bt", "<cmd>Just tags<cr>",    mode = "n", noremap = true, silent = true, desc = "Run tags task" },
            { "<leader>ba", "<cmd>JustSelect<cr>",   mode = "n", noremap = true, silent = true, desc = "Open task selector" },
            { "<leader>bs", "<cmd>JustStop<cr>",     mode = "n", noremap = true, silent = true, desc = "Stop current task" },
        },
    }
}
