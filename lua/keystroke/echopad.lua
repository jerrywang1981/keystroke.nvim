local vim = vim

local M = {}

local scale = 0.9

-- buffer number, window, window config
local _bufnr = nil
local _bufwin = nil
local _bufwinconfig = nil

local _key_table = {
  [13] = "<cr>",
  [27] = "<esc>",
  [32] = "<space>",
  [128] = "<lf>",
}

--[[
--get float buf, if no one, create one
--]]
local get_float_buf = function()
	if _bufnr then
		return _bufnr
	end
	-- create buffer
	_bufnr = vim.api.nvim_create_buf(false, true)
	return _bufnr
end

local get_float_win = function()
	if _bufwin then
		return _bufwin
	end

	local height = math.ceil(vim.o.lines * scale) - 1
	local width = math.ceil(vim.o.columns * scale)

	local row = math.ceil(vim.o.lines) - 8
	local col = math.ceil(vim.o.columns)

	local config = {
		style = "minimal",
		relative = "editor",
		anchor = "NE",
		row = row,
		col = col,
		width = math.ceil(width / 4),
		height = math.ceil(height / 4) - 1,
	}

	_bufwinconfig = config

	_bufwin = vim.api.nvim_open_win(
		_bufnr,
		false, -- do not enter into it by default
		config
	)

	vim.bo[_bufnr].filetype = "keyechopad"
	vim.cmd("setlocal nocursorcolumn")
	vim.cmd("set winblend=20")

	-- add borders
	local h = "+" .. string.rep("-", config.width - 2) .. "+"
	local l = "|" .. string.rep(" ", config.width - 2) .. "|"
	local lines = { h }
	for i = 1, config.height - 2 do
		lines[i + 1] = l
	end
	lines[config.height] = h

	vim.api.nvim_buf_set_lines(_bufnr, 0, -1, false, lines)

	return _bufwin
end

function M.start()
	get_float_buf()
	get_float_win()
end

function M.stop()
	if _bufwin then
		vim.api.nvim_win_close(_bufwin, true)
		_bufwin = nil
	end
	if _bufnr then
		vim.api.nvim_buf_delete(_bufnr, { force = true })
		_bufnr = nil
	end
end

local parse_key = function(key, opts)
	local t = vim.tbl_deep_extend("force", _key_table, opts and opts.key_table and opts.key_table or {})
	return t[string.byte(key)] or key
end

local send_to_win = function(msg)
	M.start()
	local start_col = math.ceil((_bufwinconfig.width - string.len(msg)) / 2)
	local end_col = start_col + string.len(msg)
	local current_row = math.ceil(_bufwinconfig.height / 2) - 1
	vim.api.nvim_buf_set_lines(_bufnr, current_row, current_row + 1, false, { string.rep(" ", start_col) .. msg })
end

M.send = (function()
	local msg = ""
	return function(key, opts)
		msg = msg .. parse_key(key, opts)
		-- send to buffer
		send_to_win(msg)
		-- make sure msg is not too long
		if #msg > 10 then
			msg = ""
		end
	end
end)()

return M
