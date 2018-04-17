class "__gsoSDK"
        
        function __gsoSDK:__init(menu)
                if _G.gsoSDK then return end
                _G.gsoSDK = {}
                require "gsoLibs\\AutoUpdate"
                _G.gsoSDK.AutoUpdate = __gsoAutoUpdate()
                _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\LibLoader.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/LibLoader.lua")
                require "gsoLibs\\LibLoader"
                __gsoLibLoader(menu)
        end