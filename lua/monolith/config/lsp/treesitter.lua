---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
    -- A list of parser names, or 'all'
    ensure_installed = { 'c', 'lua', 'd' },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        disable = { "d", 'dub', 'rdmd' },
    },
}

