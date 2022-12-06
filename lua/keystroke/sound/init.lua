local vim = vim
local uv = vim.loop
local path = require("keystroke.path")
local debounce = require("keystroke.debounce")

local M = {}

local sound_cmd = nil
local sound_ext = "ogg"

local sound_table = {}

local script_path = function()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)"):sub(1, -2)
end

local get_file_name_ext = function(file)
	local ext = string.match(file, "^.+%.(.+)$", -5)
	if not ext then
		return file, nil
	end
	local name = string.gsub(file, "." .. ext, "")
	return name, ext
end

local init_sound_param = function()
	if vim.fn.has("sound") == 0 then
		if vim.fn.executable("afplay") == 1 then
			sound_cmd = "afplay"
			sound_ext = "mp3"
		elseif vim.fn.executable("paplay") == 1 then
			sound_cmd = "paplay"
			sound_ext = "ogg"
		elseif vim.fn.executable("cvlc") == 1 then
			sound_cmd = { "cvls", "--play-and-exit" }
			sound_ext = "ogg"
		else
			vim.notify_once("This build of NeoVim is lacking sound support.", vim.log.levels.ERROR)
		end
	end
end

local get_sound_table = function(folder)
	if sound_table[folder] then
		return sound_table[folder]
	end
	sound_table[folder] = {}
	-- init sound param
	init_sound_param()
	-- scan the folder
	local dir = uv.fs_scandir(folder)
	local name, type = uv.fs_scandir_next(dir)

	repeat
		if type == "directory" then
			sound_table[folder][name] = {}
		end
		name, type = uv.fs_scandir_next(dir)
	until not name

	for t, _ in pairs(sound_table[folder]) do
		local p = path.join(folder, t)
		local dir = uv.fs_scandir(p)
		local name, type = uv.fs_scandir_next(dir)
		repeat
			if type == "file" then
				local n, e = get_file_name_ext(name)
				if e == sound_ext then
					sound_table[folder][t][n] = path.join(folder, t, name)
				end
			end
			name, type = uv.fs_scandir_next(dir)
		until not name
	end
	return sound_table[folder]
end

local _key_table = nil
local get_key_table = function(opts)
	if _key_table then
		return _key_table
	end
	local config = require("keystroke").config()
	local style = opts.style or "default"
	local sound_dir = opts.sound_dir or script_path()
	local t = get_sound_table(sound_dir)
	_key_table = t[style]
	if not _key_table then
		vim.notify_once("your sound style folder was not found, using default folder", vim.log.levels.ERROR)
		_key_table = t["default"]
	end
	return _key_table
end

local get_play_file = function(key, opts)
	local key_table = get_key_table(opts)
	if key_table[key] then
		return key_table[key]
	end
	-- if enter key, keycode 13
	if string.byte(key) == 13 then
		return key_table["enter"]
	end
	return key_table["default"]
end

local timer = nil

local _play = function(cmd, args)
	local handle
	local on_exit = function(code, signal)
		uv.close(handle)
	end
	handle = uv.spawn(cmd, {
		args = args,
	}, on_exit)
end

M.play_sound = function(key, opts)
	local f = get_play_file(key, opts)
	if vim.fn.has("sound") == 1 then
		vim.fn.sound_playfile(f)
		return
	end
	local cmd = sound_cmd
	local args = { f }
	if type(sound_cmd) == "table" then
		cmd = sound_cmd[1]
		table.insert(args, 1, sound_cmd[2])
	end

	if timer then
		timer:stop()
		timer = nil
	end
	fn, timer = debounce.debounce_trailing(_play, 50, false)
	fn(cmd, args)
end

return M
