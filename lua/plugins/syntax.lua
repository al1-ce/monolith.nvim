local sysdep = require("utils.sysdep")

return {
    -- 'fladson/vim-kitty', -- just a syntax file
    'tikhomirov/vim-glsl',
    -- Dart
    'dart-lang/dart-vim-plugin',
    -- Haxe
    'jdonaldson/vaxe',
    -- 'natebosch/vim-lsc'
    -- 'natebosch/vim-lsc-dart'
    {
        "NoahTheDuke/vim-just",
        event = { "BufReadPre", "BufNewFile" },
        ft = { "\\cjustfile", "*.just", ".justfile", "justfile" },
    },
    {
        "IndianBoy42/tree-sitter-just",
        dependencies = { "nvim-treesitter/nvim-treesitter" }
    },
    {
        'Fymyte/rasi.vim',
        ft = 'rasi',
    },
    {
        -- dir = "/g/al1-ce/jsl/jsl.vim"
        "jsl-lang/jsl.vim"
    },
    {
        "hat0uma/csvview.nvim",
        opts = { view = { display_mode = "border" } }
    }
}
