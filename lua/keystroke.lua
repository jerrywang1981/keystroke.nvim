local vim = vim

local M = {}

-- plugin default options/configuration
-- refer to README.md
local DEFAULT_OPTS = {
	-- auto_start
	auto_start = false,
	-- keystroke handlers
	handlers = {
		-- for insert mode
		["i"] = {},
		-- for normal mode
		["n"] = {},
		-- for all modes
		["*"] = {},
	},
}

local _config = nil

local function merge_options(conf)
	return vim.tbl_deep_extend("force", DEFAULT_OPTS, conf or {})
end

function M.setup(config)
	if vim.fn.has("nvim-0.5") == 0 then
		vim.notify_once("keystroke.lua requires Neovim 0.5 or higher", vim.log.levels.WARN)
		return
	end

	_config = merge_options(config)
end

function M.config()
	return _config or DEFAULT_OPTS
end

function M.update_config(conf)
	if _config then
		_config = vim.tbl_deep_extend("force", _config, conf or {})
	else
		DEFAULT_OPTS = vim.tbl_deep_extend("force", DEFAULT_OPTS, conf or {})
	end
end

local process_keystroke = function(flag, key)
	local isEnable = function(flag, v)
		if flag == "enable" then
			return true
		elseif flag == "disable" then
			return false
		elseif flag == "toggle" then
			local enable = true
			if v == false then
				enable = false
			end
			return not enable
		end
	end

	local c = {}
	for k, v in pairs(M.config().handlers) do
		for o, p in pairs(v) do
			if o == key then
				c[k] = c[k] or {}
				if type(p) == "table" then
					c[k][o] = {
						enable = isEnable(flag, p.enable),
					}
				elseif type(p) == "function" then
					c[k][o] = {
						enable = isEnable(flag),
						callback = p,
					}
				end
			end
		end
	end

	if next(c) ~= nil then
		M.update_config({
			handlers = c,
		})
	end
end

function M.enable()
	M.update_config({ auto_start = true })

	vim.api.nvim_create_user_command("KeyStroke", function(opts)
		process_keystroke(unpack(opts.fargs))
	end, {
		nargs = "*",
		complete = function(a, line)
			local l = vim.split(line, "%s+")
			if #l == 2 then
				return { "enable", "disable", "toggle" }
			elseif #l == 3 then
				-- get all handlers
				local handlers = M.config().handlers
				-- get all named handlers
				local options = {}
				for _, v in pairs(handlers) do
					for k, _ in pairs(v) do
						if type(k) == "string" then
							table.insert(options, k)
						end
					end
				end
				return options
			end
		end,
	})
end

function M.disable()
	M.update_config({ auto_start = false })
	vim.api.nvim_del_user_command("KeyStroke")
	-- vim.cmd [[delcommand KeyStroke]]
end

function M.toggle()
	if M.config().auto_start then
		M.disable()
	else
		M.enable()
	end
end

local run_handlers = function(handlers, key)
	if type(handlers) == "table" then
		for _, v in pairs(handlers) do
			if type(v) == "table" then
				if v.enable ~= false and v.callback then
					v.callback(key, v.options)
				end
			elseif type(v) == "function" then
				v(key)
			end
		end
	end
end

function M.handle(key)
	if M.config().auto_start then
		-- get mode
		local mode = vim.fn.mode()
		-- if the mode has handlers, then run it
		local f = M.config().handlers[mode]
		run_handlers(f, key)
		-- if there is in ['*'], run it in all modes
		f = M.config().handlers["*"]
		run_handlers(f, key)
	end
end

return M
