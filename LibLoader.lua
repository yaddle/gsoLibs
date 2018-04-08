


if _G.gsoSDK then return end



_G.gsoSDK = {}



class "__gsoLibLoader"
        
        function __gsoLibLoader:__init(menu)
                require "gsoLibs\\Utilities"
                _G.gsoSDK.Utilities = __gsoUtilities()
                require "gsoLibs\\ObjectManager"
                _G.gsoSDK.ObjectManager = __gsoOB()
                require "gsoLibs\\Farm"
                _G.gsoSDK.Farm = __gsoFarm()
                require "gsoLibs\\TS"
                _G.gsoSDK.TS = __gsoTS()
                -----------------------------------------------------------
                _G.gsoSDK.TS:CreateMenu(menu)
        end
        
        function __gsoLibLoader:Tick()
                _G.gsoSDK.ObjectManager:Tick()
                _G.gsoSDK.Utilities:Tick()
                local enemyMinions = _G.gsoSDK.ObjectManager:GetEnemyMinions(1500, false)
                local allyMinions = _G.gsoSDK.ObjectManager:GetAllyMinions(1500, false)
                _G.gsoSDK.Farm:Tick(allyMinions, enemyMinions)
        end
        
        function __gsoLibLoader:WndMsg(msg, wParam)
                _G.gsoSDK.TS:WndMsg(msg, wParam)
        end
        
        function __gsoLibLoader:Draw()
        end