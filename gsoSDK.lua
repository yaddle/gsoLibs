


if _G.gsoSDK then return end



_G.gsoSDK = {}



class "__gsoSDK"
        
        function __gsoSDK:__init(menu)
                require "gsoLibs\\AutoUpdate"
                _G.gsoSDK.AutoUpdate = __gsoAutoUpdate()
                if  _G.gsoSDK.AutoUpdate:CanUpdate(0.01, "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/LibLoader.version") then
                        _G.gsoSDK.AutoUpdate:Update(SCRIPT_PATH .. "gsoLibs\\LibLoader.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/LibLoader.lua")
                end
                require "gsoLibs\\LibLoader"
                __gsoLibLoader(menu)
        end