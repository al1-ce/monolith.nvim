if vim.g.vim_distro ~= "despair.nvim" then return end

local noremap = require("lib.map").noremap

local function paste_file(fname)
    vim.cmd("-1 read " .. fname)
end

