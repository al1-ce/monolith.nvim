local fzfp         = import "pfunc.fzf"
local colsch       = import "colorscheme"
local colorschemes = import "fzf-lua.providers.colorschemes" .colorschemes

vim.api.nvim_create_user_command("FzfLuaProjects", fzfp.FzfProjects, {})

vim.api.nvim_create_user_command("Colorschemes", function()
    colorschemes({
        actions = {
            ["default"] = function(selected, opts) colsch.set(selected[1]) end
        }
    })
end, {})
