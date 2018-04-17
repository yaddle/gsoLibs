local myHero = myHero
local gsoDelayedSpell = {}
local gsoSpellDraw = { q = false, w = false, e = false, r = false  }

local function gsoReducedDmg(unit, dmg, isAP)
        local def = isAP and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
        if def > 0 then def = isAP and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def end
        return def > 0 and dmg * ( 100 / ( 100 + def ) ) or dmg * ( 2 - ( 100 / ( 100 - def ) ) )
end

local function gsoCalculateDmg(unit, spellData)
        local dmgType = spellData.dmgType and spellData.dmgType or ""
        if not unit then assert(false, "[234] CalculateDmg: unit is nil !") end
        if dmgType == "ad" and spellData.dmgAD then
                local dmgAD = spellData.dmgAD - unit.shieldAD
                return dmgAD < 0 and 0 or gsoReducedDmg(unit, dmgAD, false) 
        elseif dmgType == "ap" and spellData.dmgAP then
                local dmgAP = spellData.dmgAP - unit.shieldAD - unit.shieldAP
                return dmgAP < 0 and 0 or gsoReducedDmg(unit, dmgAP, true) 
        elseif dmgType == "true" and spellData.dmgTrue then
                return spellData.dmgTrue - unit.shieldAD
        elseif dmgType == "mixed" and spellData.dmgAD and spellData.dmgAP then
                local dmgAD = spellData.dmgAD - unit.shieldAD
                local shieldAD = dmgAD < 0 and (-1) * dmgAD or 0
                dmgAD = dmgAD < 0 and 0 or gsoReducedDmg(unit, dmgAD, false)
                local dmgAP = spellData.dmgAP - shieldAD - unit.shieldAP
                dmgAP = dmgAP < 0 and 0 or gsoReducedDmg(unit, dmgAP, true)
                return dmgAD + dmgAP
        end
        assert(false, "[234] CalculateDmg: spellData - expected array { dmgType = string(ap or ad or mixed or true), dmgAP = number or dmgAD = number or ( dmgAP = number and dmgAD = number ) or dmgTrue = number } !")
end


class "__gsoSpell"
        
        function __gsoSpell:GetDamage(unit, spellData)
                return gsoCalculateDmg(unit, spellData)
        end
        
        function __gsoSpell:IsReady(spell)
                return gsoCursorReady and not gsoSetCursorPos and not gsoExtraSetCursor
        end
        
        local function gsoCastSpellTarget(hkSpell, range, sourcePos, target, bb)
                local castpos = target and target.pos or nil
                local bbox = bb ~= nil and target.boundingRadius or 0
                local canCast = castpos and sourcePos and gsoDistance(castpos, sourcePos) < range + bbox and castpos:ToScreen().onScreen
                if canCast then
                        local cPos = cursorPos
                        Control.SetCursorPos(castpos)
                        Control.KeyDown(hkSpell)
                        Control.KeyUp(hkSpell)

                        gsoExtraSetCursor = castpos
                        gsoState.isChangingCursorPos = true
                        gsoSetCursorPos = { endTime = gsoGetTickCount() + 50, action = function() gsoControlSetCursor(cPos.x, cPos.y) end, active = true }

                        gsoTimers.lastMoveSend = 0
                        return true
                end
                return false
        end
        
        local function gsoCastSpellSkillShot(unit, sourcePos, hkSpell, spellData, hitchance)
                if spellData.mCol or spellData.hCol then
                        if unit:GetCollision((spellData.sType == "line") and spellData.width or spellData.radius, spellData.speed, spellData.delay) > 0 then
                                return false
                        end
                end
                local castpos = unit.x and unit or nil
                if castpos == nil then
                        local isPredictedPos, predictedPos = gsoGetPrediction(unit, sourcePos, spellData, hitchance)
                        if isPredictedPos and gsoDistance(unit.pos, predictedPos) < 500 then
                                local distanceToSource = gsoDistance(sourcePos, predictedPos)
                                local width = (spellData.sType == "line") and unit.boundingRadius + spellData.width / 2.5 or 0
                                if distanceToSource > 150 and distanceToSource < spellData.range - width then
                                        castpos = predictedPos
                                end
                        end
                end
                if castpos then
                        local canCheck = false
                        if spellData.out then
                                for i = 1, 35 do
                                        local extendedPos = sourcePos:Extended(castpos, 3500 - i * 100)
                                        if extendedPos:ToScreen().onScreen then
                                                castpos = sourcePos:Extended(castpos, 3300 - i * 100)
                                                canCheck = true
                                                break
                                        end
                                end
                        end
                        if canCheck or castpos:ToScreen().onScreen then
                                local cPos = cursorPos
                                Control.SetCursorPos(castpos)
                                Control.KeyDown(hkSpell)
                                Control.KeyUp(hkSpell)
                                
                                gsoExtraSetCursor = castpos
                                gsoState.isChangingCursorPos = true
                                gsoSetCursorPos = { endTime = gsoGetTickCount() + 50, action = function() gsoControlSetCursor(cPos.x, cPos.y) end, active = true }
                                
                                gsoTimers.lastMoveSend = 0
                                return true
                        end
                end
                return false
        end
        
        function __gsoSpell:CreateMenu(menu)
                gsoMenu.gsodraw:MenuElement({name = "Spell Ranges", id = "circle1", type = MENU,
                        onclick = function()
                                if gsoSpellDraw.q then
                                        gsoMenu.gsodraw.circle1.qrange:Hide(true)
                                        gsoMenu.gsodraw.circle1.qrangecolor:Hide(true)
                                        gsoMenu.gsodraw.circle1.qrangewidth:Hide(true)
                                end
                                if gsoSpellDraw.w then
                                        gsoMenu.gsodraw.circle1.wrange:Hide(true)
                                        gsoMenu.gsodraw.circle1.wrangecolor:Hide(true)
                                        gsoMenu.gsodraw.circle1.wrangewidth:Hide(true)
                                end
                                if gsoSpellDraw.e then
                                        gsoMenu.gsodraw.circle1.erange:Hide(true)
                                        gsoMenu.gsodraw.circle1.erangecolor:Hide(true)
                                        gsoMenu.gsodraw.circle1.erangewidth:Hide(true)
                                end
                                if gsoSpellDraw.r then
                                        gsoMenu.gsodraw.circle1.rrange:Hide(true)
                                        gsoMenu.gsodraw.circle1.rrangecolor:Hide(true)
                                        gsoMenu.gsodraw.circle1.rrangewidth:Hide(true)
                                end
                        end
                })
                if gsoSpellDraw.q then
                        gsoMenu.gsodraw.circle1:MenuElement({name = "Q Range", id = "note5", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                                onclick = function()
                                        gsoMenu.gsodraw.circle1.qrange:Hide()
                                        gsoMenu.gsodraw.circle1.qrangecolor:Hide()
                                        gsoMenu.gsodraw.circle1.qrangewidth:Hide()
                                end
                        })
                        gsoMenu.gsodraw.circle1:MenuElement({id = "qrange", name = "        Enabled", value = true})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "qrangecolor", name = "        Color", color = Draw.Color(255, 66, 134, 244)})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "qrangewidth", name = "        Width", value = 1, min = 1, max = 10})
                end
                if gsoSpellDraw.w then
                        gsoMenu.gsodraw.circle1:MenuElement({name = "W Range", id = "note6", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                                onclick = function()
                                        gsoMenu.gsodraw.circle1.wrange:Hide()
                                        gsoMenu.gsodraw.circle1.wrangecolor:Hide()
                                        gsoMenu.gsodraw.circle1.wrangewidth:Hide()
                                end
                        })
                        gsoMenu.gsodraw.circle1:MenuElement({id = "wrange", name = "        Enabled", value = true})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "wrangecolor", name = "        Color", color = Draw.Color(255, 92, 66, 244)})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "wrangewidth", name = "        Width", value = 1, min = 1, max = 10})
                end
                if gsoSpellDraw.e then
                        gsoMenu.gsodraw.circle1:MenuElement({name = "E Range", id = "note7", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                                onclick = function()
                                        gsoMenu.gsodraw.circle1.erange:Hide()
                                        gsoMenu.gsodraw.circle1.erangecolor:Hide()
                                        gsoMenu.gsodraw.circle1.erangewidth:Hide()
                                end
                        })
                        gsoMenu.gsodraw.circle1:MenuElement({id = "erange", name = "        Enabled", value = true})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "erangecolor", name = "        Color", color = Draw.Color(255, 66, 244, 149)})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "erangewidth", name = "        Width", value = 1, min = 1, max = 10})
                end
                if gsoSpellDraw.r then
                        gsoMenu.gsodraw.circle1:MenuElement({name = "R Range", id = "note8", icon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png", type = SPACE,
                                onclick = function()
                                        gsoMenu.gsodraw.circle1.rrange:Hide()
                                        gsoMenu.gsodraw.circle1.rrangecolor:Hide()
                                        gsoMenu.gsodraw.circle1.rrangewidth:Hide()
                                end
                        })
                        gsoMenu.gsodraw.circle1:MenuElement({id = "rrange", name = "        Enabled", value = true})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "rrangecolor", name = "        Color", color = Draw.Color(255, 244, 182, 66)})
                        gsoMenu.gsodraw.circle1:MenuElement({id = "rrangewidth", name = "        Width", value = 1, min = 1, max = 10})
                end
        end
        
        function __gsoSpell:Draw()
                local drawMenu = gsoMenu.gsodraw.circle1
                if gsoSpellDraw.q and drawMenu.qrange:Value() then
                        local qrange = gsoSpellDraw.qf and gsoSpellDraw.qf() or gsoSpellDraw.qr
                        gsoDrawCircle(mePos, qrange, drawMenu.qrangewidth:Value(), drawMenu.qrangecolor:Value())
                end
                if gsoSpellDraw.w and drawMenu.wrange:Value() then
                        local wrange = gsoSpellDraw.wf and gsoSpellDraw.wf() or gsoSpellDraw.wr
                        gsoDrawCircle(mePos, wrange, drawMenu.wrangewidth:Value(), drawMenu.wrangecolor:Value())
                end
                if gsoSpellDraw.e and drawMenu.erange:Value() then
                        local erange = gsoSpellDraw.ef and gsoSpellDraw.ef() or gsoSpellDraw.er
                        gsoDrawCircle(mePos, erange, drawMenu.erangewidth:Value(), drawMenu.erangecolor:Value())
                end
                if gsoSpellDraw.r and drawMenu.rrange:Value() then
                        local rrange = gsoSpellDraw.rf and gsoSpellDraw.rf() or gsoSpellDraw.rr
                        gsoDrawCircle(mePos, rrange, drawMenu.rrangewidth:Value(), drawMenu.rrangecolor:Value())
                end
        end
        
        function __gsoSpell:WndMsg(msg, wParam)
                local manualNum = -1
                if wParam == HK_Q and Game.Timer() > gsoSpellTimers.lqk + 1 and Game.CanUseSpell(_Q) == 0 then
                        gsoSpellTimers.lqk = Game.Timer()
                        manualNum = 0
                elseif wParam == HK_W and Game.Timer() > gsoSpellTimers.lwk + 1 and Game.CanUseSpell(_W) == 0 then
                        gsoSpellTimers.lwk = Game.Timer()
                        manualNum = 1
                elseif wParam == HK_E and Game.Timer() > gsoSpellTimers.lek + 1 and Game.CanUseSpell(_E) == 0 then
                        gsoSpellTimers.lek = Game.Timer()
                        manualNum = 2
                elseif wParam == HK_R and Game.Timer() > gsoSpellTimers.lrk + 1 and Game.CanUseSpell(_R) == 0 then
                        gsoSpellTimers.lrk = Game.Timer()
                        manualNum = 3 end
                if manualNum > -1 and not gsoDelayedSpell[manualNum] then
                        if gsoMenu.orb.keys.combo:Value() or gsoMenu.orb.keys.harass:Value() or gsoMenu.orb.keys.lasthit:Value() or gsoMenu.orb.keys.laneclear:Value() then
                                gsoDelayedSpell[manualNum] = {
                                        function()
                                                Control.KeyDown(wParam)
                                                Control.KeyUp(wParam)
                                                Control.KeyDown(wParam)
                                                Control.KeyUp(wParam)
                                                Control.KeyDown(wParam)
                                                Control.KeyUp(wParam)
                                        end,
                                        Game.Timer()
                                }
                        end
                end
        end
        

        

