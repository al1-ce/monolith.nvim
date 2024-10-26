-- autocorrects qq to Qq
vim.cmd([[cabbrev qq Qq]])

-- custom qall command
vim.api.nvim_create_user_command('Qq', function(opts) if (opts.bang) then vim.cmd [[qall!]] else vim.cmd [[qall]] end end,
    { bang = true })

vim.api.nvim_create_user_command('Spell', function()
    vim.o.spell = not vim.o.spell
    if vim.o.spell then
        vim.notify("Turning spelling on")
    else
        vim.notify("Turning spelling off")
    end
end, {})

vim.api.nvim_create_user_command('Wrap', function()
    vim.o.wrap = not vim.o.wrap
    if vim.o.wrap then
        vim.notify("Turning wrap on")
    else
        vim.notify("Turning wrap off")
    end
end, {})
-- vim.api.nvim_create_user_command('FixColors', function() dofile(vim.fn.stdpath('config') .. "/lua/config/theme.lua") end, {})

local template = require("utils.template")
local noremap = require("map").noremap

vim.api.nvim_create_user_command('Template', template.paste_template, { range = false, nargs = '+', complete = template.autocomplete, })
vim.api.nvim_create_user_command('TemplateSelect', template.select, {})

noremap("n", "<leader>ST", template.select, { desc = "Select template with fzf and paste it under cursor" })
noremap("n", "<leader>ow", "<cmd>Wrap<cr>", { desc = "Toggle [O]ption - [W]rap" })
noremap("n", "<leader>os", "<cmd>Spell<cr>", { desc = "Toggle [O]ption - [S]pell" })

