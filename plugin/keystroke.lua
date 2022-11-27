local vim = vim
local keystroke = require("keystroke")

if 1 ~= vim.fn.has("nvim-0.5.0") then
	vim.api.nvim_err_writeln("keystroke.nvim requires at least nvim-0.5.0.")
	return
end

if vim.g.loaded_keystroke == 1 then
	return
end

vim.g.loaded_keystroke = 1

-- user commands
vim.api.nvim_create_user_command("KeyStrokeEnable", function()
	keystroke.enable()
end, {
	nargs = 0,
})

vim.api.nvim_create_user_command("KeyStrokeDisable", function()
	keystroke.disable()
end, {
	nargs = 0,
})

vim.api.nvim_create_user_command("KeyStrokeToggle", function()
	keystroke.toggle()
end, {
	nargs = 0,
})

-- start on_key
vim.on_key(function(key)
	keystroke.handle(key)
end)
