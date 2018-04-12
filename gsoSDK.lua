


if _G.gsoSDK then return end



_G.gsoSDK = {}



class "__gsoSDK"
        
        function __gsoSDK:__init(menu)
                LocalVersion = 0.01
                LocalScript = SCRIPT_PATH .. "gsoLibs\\LibLoader.lua"
                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/LibLoader.lua"
                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/GoSExt2/master/test/testUpdate.version"
                require "gsoLibs\\AutoUpdate"
                _G.gsoSDK.AutoUpdate = __gsoAutoUpdate()
                if  _G.gsoSDK.AutoUpdate:CanUpdate(f.LocalVersion, f.OnlineVersion) then
                        _G.gsoSDK.AutoUpdate:Update(f.LocalScript, f.OnlineScript)
                end
        end