--[[
-- just a demo to show when the user types in a keyword, it will
-- pop up some message
--]]
local vim = vim

local M = {}

local message = {
	["jerry"] = "Hi there, I'm Jerry Wang, Have a nice day.",
	["1958/06/30"] = [[
        七律二首·送瘟神
                        毛泽东

    春风杨柳万千条，六亿神州尽舜尧。
    红雨随心翻作浪，青山着意化为桥。
    天连五岭银锄落，地动三河铁臂摇。
    借问瘟君欲何往，纸船明烛照天烧。
  ]],
}

local key_str = ""

local check_keyword = function(keyword)
  for k, v in pairs(message) do
    local s = string.find(keyword, k, 1, true)
    if s then
      return v
    end
  end
end

M.keyword_message = function(key)
	key_str = key_str .. key
	-- if it is space key
	-- check if there is keyword match
	if key == " " then
		local msg = check_keyword(key_str)
		if msg then
			vim.notify_once(msg, vim.log.levels.INFO)
			key_str = ""
		end
	end
	-- if it is enter key
	if string.byte(key) == 13 then
		local msg = check_keyword(key_str)
		if msg then
			vim.notify_once(msg, vim.log.levels.INFO)
		end
		key_str = ""
	end
end

return M
