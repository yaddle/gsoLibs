


if _G.gsoSDK then return end



_G.gsoSDK = {}



class "__gsoSDK"
        
        function __gsoSDK:__init(menu)
                require "gsoLibs\\AutoUpdate"
                _G.gsoSDK.AutoUpdate = __gsoAutoUpdate()
                _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\LibLoader.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/LibLoader.lua")
                require "gsoLibs\\LibLoader"
                self.Loader = __gsoLibLoader(menu)
        end
        
        function __gsoSDK:Tick()
                self.Loader:Tick()
        end
        
        function __gsoSDK:WndMsg(msg, wParam)
                self.Loader:WndMsg(msg, wParam)
        end
        
        function __gsoSDK:Draw()
                self.Loader:Draw()
        end