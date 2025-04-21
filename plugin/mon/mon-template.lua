if vim.g.vim_distro ~= "monolith.nvim" then return end

local noremap = require("lib.map").noremap
noremap("n", "<leader>ST", "<cmd>TemplateSelect<cr>", { desc = "Select template with fzf and paste it under cursor" })

