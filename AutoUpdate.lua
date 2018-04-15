
local assert = assert
local type = assert(type)
local pairs = assert(pairs)
local ipairs = assert(ipairs)
local tonumber = assert(tonumber)
local tostring = assert(tostring)
local gsub = assert(string.gsub)
local char = assert(string.char)
local split = assert(string.split)
local random = assert(math.random)
local floor = assert(math.floor)

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function round(num, idp)
	local mult = 10 ^ (idp or 0)
  	return floor(num * mult + 0.5) / mult
end

local function Base64Encode(data)
    	return ((data:gsub('.', function(x) 
        	local r, b = '', x:byte()
        	for i = 8, 1, -1 do  r = r .. ( b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')  end
        	return r
    	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        	if (#x < 6) then  return '' end
        	local c = 0
        	for i = 1, 6 do  c = c + (x:sub(i,i) == '1' and 2 ^ (6 - i) or 0)  end
        	return b:sub(c + 1, c + 1)
    	end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local function Base64Decode(data)
    	data = gsub(data, '[^'..b..'=]', '')
    	return (data:gsub('.', function(x)
        	if (x == '=') then  return '' end
        	local r, f = '',(b:find(x) - 1)
        	for i = 6, 1, -1 do  r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        	return r
    	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        	if (#x ~= 8) then return '' end
        	local c = 0
        	for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
            	return char(c)
    	end))
end

local function gsoReverseString(s)
        local result = ''
        for i = #s, 1, -1 do
                result = result .. string.char(s:byte(i))
        end
        return result
end

local function gsoGetName(s, sc)
        local result = ''
        for i = #s, 1, -1 do
                local c = s:byte(i)
                if c == sc then
                        break
                end
                result = result .. string.char(c)
        end
        return gsoReverseString(result)
end

local function gsoDownloadFile(url, http)
        local socketHttp = require("gsoLibs.lua.socket.http")
        local body, code, headers, status = socketHttp.request(tostring('http://gamingonsteroids.com/GOS/TCPUpdater/GetScript' .. (http and 6 or 5) .. '.php?script=' .. Base64Encode(url) .. '&rand=' .. random(99999999)))
        if body then
                local _CS, ContentStart = body:find('<scr' .. 'ipt>')
                local ContentEnd, _CE = body:find('</scr' .. 'ipt>')
                if ContentStart and ContentEnd then
                        return true, Base64Decode(body:sub(ContentStart + 1,ContentEnd-1)), code, headers, status
                end
        end
        return false, body, code, headers, status
end

local function gsoCanUpdate(localVersion, webVersion, http)
        -- file name
        local fileName = gsoGetName(webVersion, string.byte("/"))
        -- remove http://, https://
        if webVersion:sub(1, 7) == "http://" then
                webVersion = webVersion:sub(8)
        elseif webVersion:sub(1, 8) == "https://" then
                webVersion = webVersion:sub(9)
        end
        -- local version to number
        if type(localVersion) == "string" then
                localVersion = tonumber(localVersion)
        end
        if type(localVersion) ~= "number" then
                print(tostring(fileName .. ' - Local Version is not a Number !'))
                return false
        end
        -- download version file
        local whileCount = 0
        while true do
                if whileCount == 7 then
                        break
                end
                local success, text, code, headers, status = gsoDownloadFile(webVersion, http)
                if success then
                        local onlineVersion = tonumber(text)
                        if type(onlineVersion) ~= "number" then
                                print(tostring(fileName .. ' - Online Version is not a Number !'))
                                return false
                        end
                        if onlineVersion > localVersion then
                                print(''); print(tostring(fileName .. ' - New Version found (' .. onlineVersion .. ').'))
                                return true
                        else
                                --print(tostring(fileName .. ' - No Updates Found. You have latest version (' .. localVersion .. ').'))
                                return false
                        end
                end
                whileCount = whileCount + 1
        end
        print(tostring(fileName .. ' - Error while Downloading. Please try again - 2xF6.'))
        return false
end

local function gsoSaveToFile(path, str)
        local f = io.open(path,"w+b")
        f:write(str)
        f:close()
end

local function gsoUpdate(localScript, webScript, needReload, http)
        -- file name
        local fileName = gsoGetName(webScript, string.byte("/"))
        -- remove http://, https://
        if webScript:sub(1, 7) == "http://" then
                webScript = webScript:sub(8)
        elseif webScript:sub(1, 8) == "https://" then
                webScript = webScript:sub(9)
        end
        -- download file
        local whileCount = 0
        while true do
                if whileCount == 7 then
                        break
                end
                local success, text, code, headers, status = gsoDownloadFile(webScript, http)
                if success then
                        gsoSaveToFile(localScript, text)
                        print(tostring(fileName .. ' - Successfully Downloaded !' .. (needReload and " Please Reload with 2x F6." or "")))
                        return true
                end
                whileCount = whileCount + 1
        end
        print(tostring(fileName .. ' - Error while Downloading. Please try again - 2xF6.'))
        return false
end



class '__gsoAutoUpdate'

        function __gsoAutoUpdate:CanUpdate(localVersion, webVersion, http)
                return gsoCanUpdate(localVersion, webVersion, http)
        end
        
        function __gsoAutoUpdate:Update(localScript, webScript, needReload, http)
                return gsoUpdate(localScript, webScript, needReload, http)
        end


