local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

local function setft(ftype)
    vim.bo.filetype = ftype
end

local shebangList = {
    ["node"] = "javascript",
    ["rdmd"] = "d",
    ["rund"] = "d",
    ["dub"] = "d",
    ["fish"] = "fish"
}

local function setCustomHighlight(lang)
    vim.cmd([[syn match   dCustomFunc     "\zs\(\k\w*\)*\s*\ze("]])

    if lang == "d" then
        vim.cmd([[syn match   dCustomDFunc     "\zs\(\k\w*\)*\ze\!"]])
    end
end

local function detectShebangPattern()
    for k, v in pairs(shebangList) do
        local sb = vim.api.nvim_buf_get_lines(0, 0, -1, false)[1]
        if sb == "#!/bin/" .. k or
           sb == "#!/usr/bin/" .. k or
           sb == "#!/bin/env " .. k or
           sb == "#!/usr/bin/env " .. k then
            setft(v)
            setCustomHighlight(v)
        end
    end
end

local function concat(arrays)
    local nt = {}
    for _,a in ipairs(arrays) do
        for _,v in ipairs(a) do
            table.insert(nt, v)
        end
    end
    return nt
end

-------------------- Autocmd --------------------------------------
do -- start autocmd block
    -- Languages
    local c = {"*.c", "*.h"}
    local cpp = {"*.cpp", "*.hpp"}
    local cs = {"*.cs"}
    local d = {"*.d"}
    local dart = {"*.dart"}
    local haxe = {"*.jx"}
    local go = {"*.go"}
    local java = {"*.java", "*.class"}
    local js = {"*.js"}
    local jspp = {"*.jspp", "*.jsp"}
    local kotlin = {"*.kt","*.kts","*.ktm"}
    local lua = {"*.lua"}
    local py = {"*.py"}
    local rust = {"*.rs"}
    local sdl = {"*.sdl"}
    local swift = {"*.swift"}
    local ts = {"*.ts"}

    -- Templates
    -- D templates, template!val and template!(val)
    autocmd({"BufEnter"}, { pattern = concat({d}), callback = function() setCustomHighlight("d") end })
    -- C++ templates, template<val>, no need for custom
    autocmd({"BufEnter"}, { pattern = concat({cpp, cs, dart, haxe, java, jspp, kotlin, rust, swift, ts}), callback = function() setCustomHighlight("") end })
    -- go templates, template[val], no need for custom
    autocmd({"BufEnter"}, { pattern = concat({go}), callback = function() setCustomHighlight("") end })
    -- No templates
    autocmd({"BufEnter"}, { pattern = concat({c, js, lua, py, sdl}), callback = function() setCustomHighlight("") end })

    -- Shebang
    autocmd({"BufNewFile", "BufRead"}, { pattern = {"*"}, callback = detectShebangPattern })

    augroup('YankHighlight', { clear = true })
    autocmd('TextYankPost', {
        group = 'YankHighlight',
        callback = function()
            vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
        end
    })

    autocmd({"WinEnter", "BufEnter"}, { pattern = "*", command = "setlocal cursorline" })
    autocmd({"WinLeave", "BufLeave"}, { pattern = "*", command = "setlocal nocursorline" })

    -- Set filetypes
    autocmd({"BufNewFile", "BufRead", "BufReadPost"}, {pattern = {"*.sdl"}, callback = function() setft("sdlang") end})
    autocmd({"BufNewFile", "BufRead", "BufReadPost"}, {pattern = {"*.bf"}, callback = function() setft("brainfuck") end})
    autocmd({"BufNewFile", "BufRead", "BufReadPost"}, {pattern = {"*.jpp", "*.jspp"}, callback = function() setft("sdlang") end})
    autocmd({"BufNewFile", "BufRead", "BufReadPost"}, {pattern = {"*.fasm"}, callback = function() setft("fasm") end})
    autocmd({"BufNewFile", "BufRead", "BufReadPost"}, {pattern = {"*.vs", "*.fs"}, callback = function() setft("glsl") end })
end -- end autocmd block


