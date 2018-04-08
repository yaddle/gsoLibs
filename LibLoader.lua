


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
                menu:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png", type = MENU })
                menu.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})
                _G.gsoSDK.TS:CreateDrawMenu(menu.gsodraw)
                _G.gsoSDK.Utilities:AddAction(function()
                        if _G.Orbwalker then
                                GOS.BlockMovement = true
                                GOS.BlockAttack = true
                                _G.Orbwalker.Enabled:Value(false)
                        end
                        if _G.SDK and _G.SDK.Orbwalker then
                                _G.SDK.Orbwalker:SetMovement(false)
                                _G.SDK.Orbwalker:SetAttack(false)
                        end
                        if _G.EOW then
                                _G.EOW:SetMovements(false)
                                _G.EOW:SetAttacks(false)
                        end
                end, 5)
        end
        
        function __gsoLibLoader:Tick()
                _G.gsoSDK.ObjectManager:Tick()
                _G.gsoSDK.Utilities:Tick()
                local enemyMinions = _G.gsoSDK.ObjectManager:GetEnemyMinions(1500, false)
                local allyMinions = _G.gsoSDK.ObjectManager:GetAllyMinions(1500, false)
                _G.gsoSDK.Farm:Tick(allyMinions, enemyMinions)
                _G.gsoSDK.TS:Tick()
        end
        
        function __gsoLibLoader:WndMsg(msg, wParam)
                _G.gsoSDK.TS:WndMsg(msg, wParam)
        end
        
        function __gsoLibLoader:Draw()
                 _G.gsoSDK.TS:Draw()
        end