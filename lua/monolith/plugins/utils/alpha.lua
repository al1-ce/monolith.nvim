local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local dashboard = require("alpha.themes.dashboard")

local header = {
	type = "text",
	val = {
        '',
        		"          █████████████                ▀▀▀▀▀▀██▀▀▀▀▀▀",
        		"          █████████████                      ██      ",
        		"          █████████████                ██▀▀▀▀▀▀▀▀▀▀██",
        		"          █████████████                ██▄▄▄▄▄▄▄▄▄▄██",
        		"          █████████████                  █ ██ █  ",
        		"          █████████████                 █  ██  █ ",
        		"          █████████████                              ",
        		"          █████████████                ▀▀▀██▀▀▀▀██▀▀▀",
        		"          █████████████                   ██    ██   ",
        		"          ██████████████████████       ██▀▀▀▀▀▀▀▀▀▀██",
        		"          ██████████████████████       ██▄▄▄▄▄▄▄▄▄▄██",
        		"          ██████████████████████          ██    ██   ",
        		"          ██████████████████████       ▄▄▄██▄▄▄▄██▄▄▄",
        		"          ██████████████████████                     ",
        		"          ██████████████████████       ▀▀▀▀▀▀██▀▀▀▀▀▀",
        		"          ██████████████████████       ▀▀▀▀▀▀██▀▀▀▀▀▀",
        		"          ██████████████████████       ██▀▀▀▀▀▀▀▀▀▀██",
        		"          █████████████                ██▄▄▄▄▄▄▄▄▄▄██",
        		"         █████████████                ▄▄▄▄▄▄██▄▄▄▄▄▄",
        		"        ██████████████                ▄▄▄▄▄▄██▄▄▄▄▄▄",
        		"       ███████████████                              ",
        		"      ████████████████                ▀▀▀▀▀▀██▀▀▀▀▀▀",
        		"     █████████████████                      ██      ",
        		"    ██████████████████                      ██      ",
        		"   ███████████████████                      ██      ",
        		"  ████████████████████                      ██      ",
        		" █████████████████████                      ██      ",
        		"██████████████████████                ▄▄▄▄▄▄██▄▄▄▄▄▄",
        '',
	},
	opts = {
		position = "center",
		hl = "Text",
	}
}
-- 東亜重工
-- 統和機構
-- 

local date = os.date(" %A, %b %d")

local heading = {
	type = "text",
	val = " ＴＯＨＡ ＨＥＡＶＹ ＩＮＤＵＳＴＲＩＥＳ     ∴ ",
	-- val = "𝗧𝗢𝗛𝗔 𝗛𝗘𝗔𝗩𝗬 𝗜𝗡𝗗𝗨𝗦𝗧𝗥𝗜𝗘𝗦     ⛬",
    -- also ⛬
	opts = {
		position = "center",
		hl = "Conditional",
	}
}

-- https://lingojam.com/FancyTextGenerator
local hydraHelp = "<cmd>lua require('hydra').activate(require('monolith.plugins.hydra.manual').hydra())<cr>"

local buttons = {
	type = "group",
	val = {
        dashboard.button( "∖ff", "  > ＦＩＮＤ ＦＩＬＥ" , "<cmd>Telescope find_files<cr>"),
        dashboard.button( "∖fr", "  > ＲＥＣＥＮＴ ＦＩＬＥＳ", "<cmd>Telescope oldfiles<cr>"),
        dashboard.button( "∖fp", "  > ＲＥＣＥＮＴ ＰＲＯＪＥＣＴＳ"   , "<cmd>Telescope projects<cr>"),
        dashboard.button( "∖fb", "  > ＦＩＬＥ ＢＲＯＷＳＥＲ" , "<cmd>Telescope file_browser<cr>"),
        dashboard.button( "∖ce", "  > ＯＰＥＮ ＣＯＮＦＩＧ", "<cmd>edit $MYVIMRC | tcd %:p:h<cr>"),
        dashboard.button( "∖h ", "  > ＭＡＮＵＡＬ", hydraHelp),
        dashboard.button( "e  ", "  > ＮＥＷ ＦＩＬＥ", "<cmd>enew<cr>"),
        dashboard.button( "q  ", "  > ＥＸＩＴ", "<cmd>qa<cr>"),
	},
	opts = {
		spacing = 1,
		hl = "Text"
	},
}

local footer = {
	type = "text",
	val = "Today is" .. date,
	opts = {
		position = "center",
		hl = "Conditional",
	}
}

-- local plugins_gen = io.popen('fd -d 2 . $HOME"/.local/share/nvim/site/pack/packer" | head -n -2 | wc -l | tr -d "\n" ')
-- local plugins = plugins_gen:read("*a")
-- plugins_gen:close()
local plugins = 0

if package.loaded["lazy"] then
    plugins = #(require("lazy").plugins())
end


local footer_2 = {
	type = "text",
	val = "Authority downloaded " .. plugins .. " entities to base reality",
	opts = {
		position = "center",
		hl = "Conditional",
	},
}


local section = {
	header = header,
	heading = heading,
	buttons = buttons,
	footer = footer,
	footer_2 = footer_2,
}

local opts = {
	layout = {
		{ type = "padding", val = 1 },
		section.header,
		{ type = "padding", val = 1 },
		section.heading,
		{ type = "padding", val = 1 },
		section.buttons,
		{ type = "padding", val = 1 },
		section.footer,
		{ type = "padding", val = 0 },
		section.footer_2
	},
	opts = {
		margin = 44,
	},
}

alpha.setup(opts)

-- local header = {
-- 	type = "text",
-- 	val = {
-- 		"           ███████████████                 ▀▀▀▀▀▀▀▀██▀▀▀▀▀▀▀▀",
-- 		"           ███████████████                         ██        ",
-- 		"           ███████████████                 ██████████████████",
-- 		"           ███████████████                 ██              ██",
-- 		"           ███████████████                 ██████████████████",
-- 		"           ███████████████                     ██████████    ",
-- 		"           ███████████████                   ███▀  ██  ▀███  ",
-- 		"           ███████████████                 ███▀    ██    ▀███",
-- 		"           ███████████████                                   ",
-- 		"           ███████████████                 ██████████████████",
-- 		"           ███████████████                      ██    ██     ",
-- 		"           ███████████████                      ██    ██     ",
-- 		"           ██████████████████████████      ██▀▀▀▀▀▀▀▀▀▀▀▀▀▀██",
-- 		"           ██████████████████████████      ██              ██",
-- 		"           ██████████████████████████      ▀▀▀▀▀██▀▀▀▀██▀▀▀▀▀",
-- 		"           ██████████████████████████           ██    ██     ",
-- 		"           ██████████████████████████           ██    ██     ",
-- 		"           ██████████████████████████      ██████████████████",
-- 		"           ██████████████████████████                        ",
-- 		"           ██████████████████████████      ▀▀▀▀▀▀▀▀██▀▀▀▀▀▀▀▀",
-- 		"           ██████████████████████████      ▀▀▀▀▀▀▀▀██▀▀▀▀▀▀▀▀",
-- 		"           ██████████████████████████      ██████████████████",
-- 		"           ███████████████▀▀▀▀▀▀▀▀▀▀▀      ██              ██",
-- 		"           ███████████████                 ██████████████████",
-- 		"          ███████████████                 ▄▄▄▄▄▄▄▄██▄▄▄▄▄▄▄▄",
-- 		"         ████████████████                 ▄▄▄▄▄▄▄▄██▄▄▄▄▄▄▄▄",
-- 		"        █████████████████                                   ",
-- 		"       ██████████████████                 ██████████████████",
-- 		"      ███████████████████                         ██        ",
-- 		"     ████████████████████                         ██        ",
-- 		"    █████████████████████                         ██        ",
-- 		"   ██████████████████████                         ██        ",
-- 		"  ███████████████████████                         ██        ",
-- 		" ████████████████████████                         ██        ",
-- 		"█████████████████████████                 ██████████████████",
-- 	},
-- 	opts = {
-- 		position = "center",
-- 		hl = "Text",
-- 	}
-- }
