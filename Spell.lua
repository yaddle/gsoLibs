local myHero = myHero

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
                return _G.gsoSDK.Cursor.IsCursorReady() and Game.CanUseSpell(spell) == 0
        end
        
        function __gsoSpell:CastSpell(spell, target)
                if not spell then return false end
                if spell == _Q then
                        spell = HK_Q
                elseif spell == _W then
                        spell = HK_W
                elseif spell == _E then
                        spell = HK_E
                elseif spell == _R then
                        spell = HK_R
                end
                if not target then
                        Control.KeyDown(spell)
                        Control.KeyUp(spell)
                        return true
                else
                        local castpos = target.x and target or target.pos
                        if castpos:ToScreen().onScreen then
                                _G.gsoSDK.Cursor:SetCursor(cursorPos, castpos, 0.06)
                                Control.SetCursorPos(castpos)
                                Control.KeyDown(spell)
                                Control.KeyUp(spell)
                                _G.gsoSDK.Orbwalker:ResetMove()
                                return true
                        end
                end
                return false
        end