local function gsoFileExist(path)
        local f = io.open(path,"r")
        if f ~= nil then io.close(f) return true else return false end
end

local function gsoReadFile(path)
        local f = assert(io.open(path, "rb"))
        local content = f:read("*all")
        f:close()
        return content
end

class "__gsoLibLoader"
        
        function __gsoLibLoader:__init(menu)
                self.menu = menu
                _G.gsoTicks = { All = true, ObjectManager = true, Utilities = true, Cursor = true,  Farm = true, Noddy = true }
                _G.gsoDraws = { All = true, Spell = true, Cursor = true, TargetSelector = true }
                -- update due github delays. In 30 minutes these lines will be removed
                _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "HPred.lua", "https://raw.githubusercontent.com/Sikaka/GOSExternal/master/HPred.lua", false, false, false)
                _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Prediction.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Prediction.lua", false, false, false)
                if not gsoFileExist(COMMON_PATH.."gsoLibs\\gsoSDK.version") or _G.gsoSDK.AutoUpdate:CanUpdate(assert(tonumber(gsoReadFile(COMMON_PATH .. "gsoLibs\\gsoSDK.version"))), "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/gsoSDK.version") then
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\gsoSDK.version", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/gsoSDK.version", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\AutoUpdate.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/AutoUpdate.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Cursor.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Cursor.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Farm.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Farm.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\ObjectManager.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/ObjectManager.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Orbwalker.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Orbwalker.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\TS.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/TS.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Utilities.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Utilities.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Activator.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Activator.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Prediction.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Prediction.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\Spell.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Spell.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\gsoSDK.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/gsoSDK.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "gsoLibs\\LibLoader.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/LibLoader.lua", false, false, false)
                        print("gsoLibs - Successfully Downloaded !")
                else
                        print("gsoLibs - No Updates Found.")
                end
                -- HPred Prediction
                if not _G.gsoSDK.AutoUpdate:FileExists(COMMON_PATH.."HPred.lua") then
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "HPred.lua", "https://raw.githubusercontent.com/Sikaka/GOSExternal/master/HPred.lua", false, false, false)
                end
                -- TRUS Prediction
                if not _G.gsoSDK.AutoUpdate:FileExists(COMMON_PATH.."TPred.lua") then
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "TPred.lua", "https://raw.githubusercontent.com/Vasilyi/gamingonsteroids/master/Common/TPred.lua", false, false, false)
                end
                -- evitaerCi Orbwalker
                if not _G.gsoSDK.AutoUpdate:FileExists(SCRIPT_PATH .. "Orbwalker.lua") then
                        _G.gsoSDK.AutoUpdate:Update(SCRIPT_PATH .. "Orbwalker.lua", "https://raw.githubusercontent.com/jachicao/GoS/master/src/Orbwalker.lua", false, false, false)
                end
                -- update all libs
                if _G.gsoSDK.AutoUpdate:CanUpdate(0.01, "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Libs.version") then
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "HPred.lua", "https://raw.githubusercontent.com/Sikaka/GOSExternal/master/HPred.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(COMMON_PATH .. "TPred.lua", "https://raw.githubusercontent.com/Vasilyi/gamingonsteroids/master/Common/TPred.lua", false, false, false)
                        _G.gsoSDK.AutoUpdate:Update(SCRIPT_PATH .. "Orbwalker.lua", "https://raw.githubusercontent.com/jachicao/GoS/master/src/Orbwalker.lua", false, false, false)
                end
                self.selmenu = MenuElement({name = "Orbwalker & Prediction", id = "gsoorbsel", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/seliconjs7sdq.png" })
                self.selmenu:MenuElement({ id = "orbsel", name = "Orbwalker", value = 1, drop = { "Gamsteron", "GOS", "IC" } })
                self.selmenu:MenuElement({ id = "predsel", name = "Prediction", value = 1, drop = { "Noddy - Pred", "Trus - TPred", "Sikaka - HPred", "Gamsteron - Pred ( not ready yet )" } })
                -- LOAD LIBS
                require "gsoLibs\\Spell"
                _G.gsoSDK.Spell = __gsoSpell()
                require "gsoLibs\\Prediction"
                _G.gsoSDK.Prediction = __gsoPrediction(self.selmenu)
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
                _G.gsoSDK.TS:CreateMenu(menu)
                _G.gsoSDK.Orbwalker:CreateMenu(menu, self.selmenu)
                menu:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png", type = MENU })
                menu.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})
                _G.gsoSDK.Spell:CreateDrawMenu(menu.gsodraw)
                _G.gsoSDK.TS:CreateDrawMenu(menu.gsodraw)
                _G.gsoSDK.Cursor:CreateDrawMenu(menu.gsodraw)
                _G.gsoSDK.Orbwalker:CreateDrawMenu(menu.gsodraw)
                Callback.Add('Tick', function()
                        _G.gsoSDK.Prediction:Tick()
                        if self.selmenu.orbsel:Value() == 1 then
                                _G.gsoSDK.ObjectManager:Tick()
                                _G.gsoSDK.Utilities:Tick()
                                _G.gsoSDK.Cursor:Tick()
                                local enemyMinions = _G.gsoSDK.ObjectManager:GetEnemyMinions(1500, false)
                                local allyMinions = _G.gsoSDK.ObjectManager:GetAllyMinions(1500, false)
                                _G.gsoSDK.Farm:Tick(allyMinions, enemyMinions)
                                _G.gsoSDK.TS:Tick()
                        elseif _G.gsoTicks.All then
                                if _G.gsoTicks.Utilities then
                                        _G.gsoSDK.Utilities:Tick()
                                end
                                if _G.gsoTicks.Cursor then
                                        _G.gsoSDK.Cursor:Tick()
                                end
                                if _G.gsoTicks.ObjectManager then
                                        _G.gsoSDK.ObjectManager:Tick()
                                        if _G.gsoTicks.Farm then
                                                local enemyMinions = _G.gsoSDK.ObjectManager:GetEnemyMinions(1500, false)
                                                local allyMinions = _G.gsoSDK.ObjectManager:GetAllyMinions(1500, false)
                                                _G.gsoSDK.Farm:Tick(allyMinions, enemyMinions)
                                        end
                                end
                        end
                        _G.gsoSDK.Orbwalker:Tick()
                end)
                Callback.Add('WndMsg', function(msg, wParam)
                        _G.gsoSDK.TS:WndMsg(msg, wParam)
                        _G.gsoSDK.Orbwalker:WndMsg(msg, wParam)
                        _G.gsoSDK.Spell:WndMsg(msg, wParam)
                end)
                Callback.Add('Draw', function()
                        if not self.menu.gsodraw.enabled:Value() then return end
                        if self.selmenu.orbsel:Value() == 1 then
                                _G.gsoSDK.TS:Draw()
                                _G.gsoSDK.Cursor:Draw()
                        elseif _G.gsoTicks.All then
                                if _G.gsoDraws.TargetSelector then
                                        _G.gsoSDK.TS:Draw()
                                end
                                if _G.gsoDraws.Cursor then
                                        _G.gsoSDK.Cursor:Draw()
                                end
                        end
                        if _G.gsoDraws.Spell then
                                _G.gsoSDK.Spell:Draw()
                        end
                        _G.gsoSDK.Orbwalker:Draw()
                end)
        end