if vim.g.vim_distro ~= "despair.nvim" then return end

local noremap = require("lib.remap").noremap

local function paste_file(fname)
    vim.cmd("-1 read " .. fname)
end

