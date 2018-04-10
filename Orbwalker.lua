local gsoLoadTime = Game.Timer()
local gsoIsTeemo = false
local gsoIsBlindedByTeemo = false
local gsoLastAttackLocal = 0
local gsoLastAttackServer = 0
local gsoLastAttackServerSpell = 0
local gsoLastMoveLocal = 0
local gsoServerStart = 0
local gsoMainMenu = nil
local gsoMenu = nil
local gsoDrawMenuMe = nil
local gsoDrawMenuHe = nil
local gsoLastMouseDown = 0
local gsoLastMovePos = myHero.pos
local gsoResetAttack = false
local gsoLastTarget = nil
local gsoTestCount = 0
local gsoTestStartTime = 0
local gsoLastAttackDiff = 0
local gsoBaseAASpeed = 1 / myHero.attackData.animationTime / myHero.attackSpeed
local gsoBaseWindUp = myHero.attackData.windUpTime / myHero.attackData.animationTime
local gsoAttackEndTime = myHero.attackData.endTime + 0.1
local gsoWindUpTime = myHero.attackData.windUpTime
local gsoAnimTime = myHero.attackData.animationTime
local gsoNoAttacks = {
    ["volleyattack"] = true,
    ["volleyattackwithsound"] = true,
    ["sivirwattackbounce"] = true,
    ["asheqattacknoonhit"] = true
}
local gsoAttacks = {
    ["caitlynheadshotmissile"] = true,
    ["quinnwenhanced"] = true,
    ["viktorqbuff"] = true
}

local function gsoGetAttackSpeed()
        return myHero.attackSpeed
end

local function gsoGetAvgLatency()
        local currentLatency = Game.Latency() * 0.001
        local latency = _G.gsoSDK.Utilities:GetMinLatency() + _G.gsoSDK.Utilities:GetMaxLatency() + currentLatency
        return latency / 3
end

local function gsoSetAttackTimers()
        gsoBaseAASpeed = 1 / myHero.attackData.animationTime / myHero.attackSpeed
        gsoBaseWindUp = myHero.attackData.windUpTime / myHero.attackData.animationTime
        local aaSpeed = gsoGetAttackSpeed() * gsoBaseAASpeed
        local animT = 1 / aaSpeed
        local windUpT = animT * gsoBaseWindUp
        gsoAnimTime = animT > myHero.attackData.animationTime and animT or myHero.attackData.animationTime
        gsoWindUpTime = windUpT > myHero.attackData.windUpTime and windUpT or myHero.attackData.windUpTime
end

local function gsoCheckTeemoBlind()
        for i = 0, gsoMyHero.buffCount do
                local buff = gsoMyHero:GetBuff(i)
                if buff and buff.count > 0 and buff.name:lower() == "blindingdart" and buff.duration > 0 then
                        return true
                end
        end
        return false
end

class "__gsoOrbwalker"
        
        function __gsoOrbwalker:__init()
                self.Loaded = false
                self.UOL_Loaded = { Icy = false, Gamsteron = false, Gos = false }
                _G.gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) if hero.charName == "Teemo" then gsoIsTeemo = true end end)
        end
        
        function __gsoOrbwalker:GetLastMovePos()
                return gsoLastMovePos
        end
        
        function __gsoOrbwalker:ResetAttack()
                gsoResetAttack = true
        end
        
        function __gsoOrbwalker:GetLastTarget()
                return gsoLastTarget
        end
        
        function __gsoOrbwalker:CreateMenu(menu)
                gsoMainMenu = menu
                gsoMenu = gsoMainMenu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png" })
                        gsoMenu:MenuElement({name = "Enabled",  id = "enabledorb", value = true})
                        gsoMenu:MenuElement({name = "Keys", id = "keys", type = MENU})
                                gsoMenu.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
                                gsoMenu.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
                                gsoMenu.keys:MenuElement({name = "LastHit Key", id = "lasthit", key = string.byte("X")})
                                gsoMenu.keys:MenuElement({name = "LaneClear Key", id = "laneclear", key = string.byte("V")})
                        gsoMenu:MenuElement({name = "Extra WindUp Delay [ less = better KITE ]", id = "windupdelay", value = 20, min = 0, max = 150, step = 10 })
                        gsoMenu:MenuElement({name = "Extra Anim Delay [ less = better DPS ]", id = "animdelay", value = 80, min = 0, max = 150, step = 10 })
                        gsoMenu:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = -50, max = 50, step = 1 })
                        gsoMenu:MenuElement({name = "Extra Move Delay", id = "humanizer", value = 200, min = 120, max = 300, step = 10 })
                        gsoMenu:MenuElement({name = "Debug Mode",  id = "enabled", value = false})
        end
        
        function __gsoOrbwalker:EnableGamsteronOrb()
                if not gsoMenu.enabledorb:Value() then gsoMenu.enabledorb:Value(true) end
                gsoMenu:Hide(false)
                self.UOL_Loaded.Gamsteron = true
        end
        
        function __gsoOrbwalker:DisableGamsteronOrb()
                if gsoMenu.enabledorb:Value() then gsoMenu.enabledorb:Value(false) end
                gsoMenu:Hide(true)
                self.UOL_Loaded.Gamsteron = false
        end
        
        function __gsoOrbwalker:EnableGosOrb()
                if not _G.Orbwalker.Enabled:Value() then _G.Orbwalker.Enabled:Value(true) end
                _G.Orbwalker:Hide(false)
                self.UOL_Loaded.Gos = true
        end
        
        function __gsoOrbwalker:DisableGosOrb()
                if _G.Orbwalker.Enabled:Value() then _G.Orbwalker.Enabled:Value(false) end
                _G.Orbwalker:Hide(true)
                self.UOL_Loaded.Gos = false
        end
        
        function __gsoOrbwalker:EnableIcyOrb()
                if _G.SDK and _G.SDK.Orbwalker and _G.SDK.Orbwalker.Loaded then
                        if not _G.SDK.Orbwalker.Menu.Enabled:Value() then _G.SDK.Orbwalker.Menu.Enabled:Value(true) end
                        _G.SDK.Orbwalker.Menu:Hide(false)
                        self.UOL_Loaded.Icy = true
                end
        end
        
        function __gsoOrbwalker:DisableIcyOrb()
                if _G.SDK and _G.SDK.Orbwalker and _G.SDK.Orbwalker.Loaded then
                        if _G.SDK.Orbwalker.Menu.Enabled:Value() then _G.SDK.Orbwalker.Menu.Enabled:Value(false) end
                        _G.SDK.Orbwalker.Menu:Hide(true)
                        self.UOL_Loaded.Icy = false
                end
        end
        
        ------------------------------------------------------------------------ UOL START
        function __gsoOrbwalker:UOL()
                if not self.Loaded and Game.Timer() > gsoLoadTime + 2.5 then
                        self.Loaded = true
                end
                if not self.Loaded then return end
                if gsoMainMenu.orbsel:Value() == 1 then
                        self:DisableIcyOrb()
                        self:DisableGosOrb()
                        self:EnableGamsteronOrb()
                elseif gsoMainMenu.orbsel:Value() == 2 then
                        self:DisableIcyOrb()
                        self:EnableGosOrb()
                        self:DisableGamsteronOrb()
                elseif gsoMainMenu.orbsel:Value() == 3 then
                        if not _G.SDK or not _G.SDK.Orbwalker then
                                print("To use IcyOrbwalker you need load it !")
                                gsoMainMenu.orbsel:Value(1)
                        else
                                self:EnableIcyOrb()
                                self:DisableGosOrb()
                                self:DisableGamsteronOrb()
                        end
                end
        end
        function __gsoOrbwalker:UOL_CanMove()
                if gsoMainMenu.orbsel:Value() == 1 then
                        return self:CanMove()
                elseif gsoMainMenu.orbsel:Value() == 2 then
                        return GOS:CanMove()
                elseif gsoMainMenu.orbsel:Value() == 3 then
                        return _G.SDK.Orbwalker:CanMove(myHero)
                end
        end
        function __gsoOrbwalker:UOL_CanAttack()
                if gsoMainMenu.orbsel:Value() == 1 then
                        return self:CanAttack()
                elseif gsoMainMenu.orbsel:Value() == 2 then
                        return GOS:CanAttack()
                elseif gsoMainMenu.orbsel:Value() == 3 then
                        return _G.SDK.Orbwalker:CanAttack(myHero)
                end
        end
        function __gsoOrbwalker:UOL_IsAttacking()
                if gsoMainMenu.orbsel:Value() == 1 then
                        return not self:CanMove()
                elseif gsoMainMenu.orbsel:Value() == 2 then
                        return GOS:IsAttacking()
                elseif gsoMainMenu.orbsel:Value() == 3 then
                        return IsAutoAttacking(myHero)
                end
        end
        ------------------------------------------------------------------------ UOL END
        
        function __gsoOrbwalker:CreateDrawMenu(menu)
                gsoDrawMenuMe = menu:MenuElement({name = "MyHero Attack Range", id = "me", type = MENU})
                        gsoDrawMenuMe:MenuElement({name = "Enabled",  id = "enabled", value = true})
                        gsoDrawMenuMe:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 49, 210, 0)})
                        gsoDrawMenuMe:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                gsoDrawMenuHe = menu:MenuElement({name = "Enemy Attack Range", id = "he", type = MENU})
                        gsoDrawMenuHe:MenuElement({name = "Enabled",  id = "enabled", value = true})
                        gsoDrawMenuHe:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 255, 0, 0)})
                        gsoDrawMenuHe:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
        end
        
        function __gsoOrbwalker:WndMsg(msg, wParam)
                if wParam == HK_TCO then
                        gsoLastAttackLocal = Game.Timer()
                end
        end
        
        function __gsoOrbwalker:Draw()
                if not gsoMenu.enabledorb:Value() then return end
                if gsoDrawMenuMe.enabled:Value() and myHero.pos:ToScreen().onScreen then
                        Draw.Circle(myHero.pos, myHero.range + myHero.boundingRadius + 35, gsoDrawMenuMe.width:Value(), gsoDrawMenuMe.color:Value())
                end
                if gsoDrawMenuHe.enabled:Value() then
                        local enemyHeroes = _G.gsoSDK.ObjectManager:GetEnemyHeroes(99999999, false, "immortal")
                        for i = 1, #enemyHeroes do
                                local enemy = enemyHeroes[i]
                                if enemy.pos:ToScreen().onScreen then
                                        Draw.Circle(enemy.pos, enemy.range + enemy.boundingRadius + 35, gsoDrawMenuHe.width:Value(), gsoDrawMenuHe.color:Value())
                                end
                        end
                end
        end
        
        ------------------------------------------------------------
        ------------------------------------------------------------
        ------------------------------------------------------------
        
        function __gsoOrbwalker:Attack(unit)
                gsoResetAttack = false
                _G.gsoSDK.Cursor:SetCursor(cursorPos, unit.pos, 0.06)
                Control.SetCursorPos(unit.pos)
                Control.KeyDown(HK_TCO)
                Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                Control.KeyUp(HK_TCO)
                gsoLastMoveLocal = 0
                gsoLastAttackLocal  = Game.Timer()
                gsoLastTarget = unit
        end
        
        function __gsoOrbwalker:Move()
                if Control.IsKeyDown(2) then gsoLastMouseDown = Game.Timer() end
                gsoLastMovePos = mousePos
                Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                gsoLastMoveLocal = Game.Timer() + gsoMenu.humanizer:Value() * 0.001
        end
        
        function __gsoOrbwalker:CanAttack()
                if gsoIsBlindedByTeemo then
                        return false
                end
                if gsoResetAttack then
                        return true
                end
                local animDelay = gsoMenu.animdelay:Value() * 0.001
                if Game.Timer() < gsoLastAttackLocal + gsoAnimTime + gsoLastAttackDiff + animDelay - 0.15 - gsoGetAvgLatency() then
                        return false
                end
                return true
        end
        
        function __gsoOrbwalker:CanMove()
                local latency = math.min(_G.gsoSDK.Utilities:GetMinLatency(), Game.Latency() * 0.001) * 0.75
                local windUpDelay = gsoMenu.windupdelay:Value() * 0.001
                if Game.Timer() < gsoLastAttackLocal + gsoWindUpTime + gsoLastAttackDiff - latency - 0.025 + windUpDelay then
                        return false
                end
                if gsoLastAttackLocal > gsoLastAttackServer and Game.Timer() < gsoLastAttackLocal + gsoWindUpTime + gsoLastAttackDiff - latency + 0.025 + windUpDelay then return false end
                return true
        end
        
        function __gsoOrbwalker:AttackMove(unit)
                gsoLastTarget = nil
                if unit and unit.pos:ToScreen().onScreen and self:CanAttack() then
                        self:Attack(unit)
                elseif Game.Timer() > gsoLastMoveLocal and self:CanMove() then
                        self:Move()
                end
        end
        
        function __gsoOrbwalker:Tick()
                self:UOL()
                if not gsoMenu.enabledorb:Value() then return end
                if gsoIsTeemo then gsoIsBlindedByTeemo = gsoCheckTeemoBlind() end
                -- SERVER ATTACK START TIME
                if myHero.attackData.endTime > gsoAttackEndTime then
                        local serverStart = myHero.attackData.endTime - myHero.attackData.animationTime
                        gsoLastAttackDiff = serverStart - gsoLastAttackLocal
                        gsoLastAttackServer = Game.Timer()
                        gsoAttackEndTime = myHero.attackData.endTime
                        if gsoMenu.enabled:Value() then
                                if gsoTestCount == 0 then
                                        gsoTestStartTime = Game.Timer()
                                end
                                gsoTestCount = gsoTestCount + 1
                                if gsoTestCount == 5 then
                                        print("5 attacks in time: " .. tostring(Game.Timer() - gsoTestStartTime) .. "[sec]")
                                        gsoTestCount = 0
                                        gsoTestStartTime = 0
                                end
                        end
                end
                -- SPELL ATTACK TIME
                local aSpell = myHero.activeSpell
                if aSpell and aSpell.valid and aSpell.startTime > gsoServerStart then
                        local aSpellName = aSpell.name:lower()
                        if not gsoNoAttacks[aSpellName] and (aSpellName:find("attack") or gsoAttacks[aSpellName]) then
                                gsoLastAttackServerSpell = Game.Timer()
                                gsoServerStart = aSpell.startTime
                                --[[gsoServerWindup = aSpell.windup
                                gsoServerAnim = aSpell.animation--]]
                        end
                end
                -- RESET ATTACK
                if gsoLastAttackLocal > gsoLastAttackServer and Game.Timer() > gsoLastAttackLocal + 0.15 + _G.gsoSDK.Utilities:GetMaxLatency() then
                        if gsoMenu.enabled:Value() then
                                print("reset attack1")
                        end
                        gsoLastAttackLocal = 0
                elseif gsoLastAttackLocal < gsoLastAttackServer and Game.Timer() < gsoLastAttackLocal + myHero.attackData.windUpTime and myHero.pathing.hasMovePath then
                        if gsoMenu.enabled:Value() then
                                print("reset attack2")
                        end
                        gsoLastAttackLocal = 0
                elseif gsoLastAttackLocal > gsoLastAttackServerSpell and Game.Timer() > gsoLastAttackLocal + myHero.attackData.windUpTime + 0.1 + _G.gsoSDK.Utilities:GetMaxLatency() then
                        if gsoMenu.enabled:Value() then
                                print("reset attack3")
                        end
                        gsoLastAttackLocal = 0
                end
                -- ATTACK TIMERS
                gsoSetAttackTimers()
                -- CHECK IF CAN ORBWALK
                local isEvading = ExtLibEvade and ExtLibEvade.Evading
                if not _G.gsoSDK.Cursor:IsCursorReady() or Game.IsChatOpen() or isEvading then
                        return
                end
                -- ORBWALKER MODE
                if gsoMenu.keys.combo:Value() then
                        self:AttackMove(_G.gsoSDK.TS:GetComboTarget())
                elseif gsoMenu.keys.harass:Value() then
                        if _G.gsoSDK.Farm:CanLastHit() then
                                self:AttackMove(_G.gsoSDK.TS:GetLastHitTarget())
                        else
                                self:AttackMove(_G.gsoSDK.TS:GetComboTarget())
                        end
                elseif gsoMenu.keys.lasthit:Value() then
                        self:AttackMove(_G.gsoSDK.TS:GetLastHitTarget())
                elseif gsoMenu.keys.laneclear:Value() then
                        if _G.gsoSDK.Farm:CanLastHit() then
                                self:AttackMove(_G.gsoSDK.TS:GetLastHitTarget())
                        elseif _G.gsoSDK.Farm:CanLaneClear() then
                                self:AttackMove(_G.gsoSDK.TS:GetLaneClearTarget())
                        else
                                self:AttackMove()
                        end
                elseif Game.Timer() < gsoLastMouseDown + 1 then
                        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                        gsoLastMouseDown = 0
                end
        end