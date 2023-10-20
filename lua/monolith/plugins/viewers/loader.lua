local function load(m)
    local ok, err = pcall(require, "monolith.plugins.viewers." .. m)
    if not ok then
        vim.api.nvim_err_writeln("Package \"" .. m .. "\" failed to load. \n\n" .. err)
        return
    end
    return ok
end

load("glow")