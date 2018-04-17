class "__gsoLibLoader"
        
        function __gsoLibLoader:__init(menu)
                -- AUTO UPDATE
                self.FilesToDownload = {
                        {
                                LocalVersion = 0.02,
                                LocalScript = COMMON_PATH .. "gsoLibs\\AutoUpdate.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/AutoUpdate.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/AutoUpdate.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Cursor.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Cursor.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Cursor.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Farm.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Farm.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Farm.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\ObjectManager.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/ObjectManager.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/ObjectManager.version"
                        },
                        {
                                LocalVersion = 0.02,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Orbwalker.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Orbwalker.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Orbwalker.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\TS.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/TS.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/TS.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Utilities.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Utilities.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Utilities.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Activator.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Activator.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Activator.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Prediction.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Prediction.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Prediction.version"
                        },
                        {
                                LocalVersion = 0.01,
                                LocalScript = COMMON_PATH .. "gsoLibs\\Spell.lua",
                                OnlineScript = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Spell.lua",
                                OnlineVersion = "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/version/Spell.version"
                        }
                }
                local boolean = false
                for i = 1, #self.FilesToDownload do
                        local f = self.FilesToDownload[i]
                        if _G.gsoSDK.AutoUpdate:CanUpdate(f.LocalVersion, f.OnlineVersion) then
                                boolean = true
                                _G.gsoSDK.AutoUpdate:Update(f.LocalScript, f.OnlineScript)
                        end
                end
                if not boolean then
                        print("gsoLibs - No Updates Found.")
                end
                -- LOAD LIBS
                require "gsoLibs\\Utilities"
                _G.gsoSDK.Utilities = __gsoUtilities()
                require "gsoLibs\\Cursor"
                _G.gsoSDK.Cursor = __gsoCursor()
                require "gsoLibs\\ObjectManager"
                _G.gsoSDK.ObjectManager = __gsoOB()
                require "gsoLibs\\Farm"
                _G.gsoSDK.Farm = __gsoFarm()
                require "gsoLibs\\TS"
                _G.gsoSDK.TS = __gsoTS()
                require "gsoLibs\\Orbwalker"
                _G.gsoSDK.Orbwalker = __gsoOrbwalker()
                -----------------------------------------------------------
                -- MENU
                self.selmenu = MenuElement({name = "Orbwalker & Prediction & TS", id = "gsoorbsel", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/seliconjs7sdq.png" })
                self.selmenu:MenuElement({ id = "orbsel", name = "Orbwalker", value = 1, drop = { "Gamsteron", "GOS", "IC" } })
                self.selmenu:MenuElement({ id = "tssel", name = "Target Selector", value = 1, drop = { "Gamsteron", "GOS", "IC" } })
                self.selmenu:MenuElement({ id = "predsel", name = "Prediction", value = 1, drop = { "Noddy", "Trus", "Sikaka", "Toshibiotro" } })
                _G.gsoSDK.TS:CreateMenu(menu)
                _G.gsoSDK.Orbwalker:CreateMenu(menu, self.selmenu)
                menu:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png", type = MENU })
                menu.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})
                _G.gsoSDK.TS:CreateDrawMenu(menu.gsodraw)
                _G.gsoSDK.Cursor:CreateDrawMenu(menu.gsodraw)
                _G.gsoSDK.Orbwalker:CreateDrawMenu(menu.gsodraw)
        end
        
        function __gsoLibLoader:Tick()
                _G.gsoSDK.ObjectManager:Tick()
                _G.gsoSDK.Utilities:Tick()
                _G.gsoSDK.Cursor:Tick()
                local enemyMinions = _G.gsoSDK.ObjectManager:GetEnemyMinions(1500, false)
                local allyMinions = _G.gsoSDK.ObjectManager:GetAllyMinions(1500, false)
                _G.gsoSDK.Farm:Tick(allyMinions, enemyMinions)
                _G.gsoSDK.TS:Tick()
                _G.gsoSDK.Orbwalker:Tick()
        end
        
        function __gsoLibLoader:WndMsg(msg, wParam)
                _G.gsoSDK.TS:WndMsg(msg, wParam)
                _G.gsoSDK.Orbwalker:WndMsg(msg, wParam)
        end
        
        function __gsoLibLoader:Draw()
                 _G.gsoSDK.TS:Draw()
                 _G.gsoSDK.Cursor:Draw()
                 _G.gsoSDK.Orbwalker:Draw()
        end