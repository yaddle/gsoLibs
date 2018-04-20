--local champInfo = { lastASCheck = 0, asNoQ = myHero.attackSpeed, windUpNoQ = myHero.attackData.windUpTime }

local gsoHasQBuff = false
local gsoQBuffDuration = 0

local gsoHasQASBuff = false
local gsoQASBuffDuration = 0

local gsoRecall = true

local gsoEBuffs = {}

class "__gsoTwitch"

        function __gsoTwitch:__init()
                self.menu = MenuElement({name = "Gamsteron Twitch", id = "gsotwitch", type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png" })
                require "gsoLibs\\gsoSDK"
                __gsoSDK(self.menu)
                if _G.gsoSDK.AutoUpdate:CanUpdate(0.01, "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/GamsteronAIO/Twitch/gsoTwitch.version") then
                        _G.gsoSDK.AutoUpdate:Update(SCRIPT_PATH .. "gsoTwitch.lua", "https://raw.githubusercontent.com/gamsteron/gsoLibs/master/GamsteronAIO/Twitch/gsoTwitch.lua", true, false, true)
                else
                        print("gsoTwitch - No Updates Found.")
                end
                _G.gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0, w = 0.2, e = 0.2, r = 0 } )
                _G.gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0, w = 0.33, e = 0.33, r = 0 } )
                self:SetSpellData()
                self:CreateMenu()
                self:CreateDrawMenu()
                self:AddDrawEvent()
                self:AddTickEvent()
        end
        
        function __gsoTwitch:SetSpellData()
                self.wData = { delay = 0.25, radius = 275, range = 950, speed = 1400, collision = false, sType = "circular" }
        end
        
        function __gsoTwitch:CreateMenu()
                self.menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
                        self.menu.qset:MenuElement({id = "recallkey", name = "Invisible Recall Key", key = string.byte("T"), value = false, toggle = true})
                        self.menu.qset.recallkey:Value(false)
                        self.menu.qset:MenuElement({id = "note1", name = "Note: Key should be diffrent than recall key", type = SPACE})
                self.menu:MenuElement({name = "W settings", id = "wset", type = MENU })
                        self.menu.wset:MenuElement({id = "stopq", name = "Stop if Q invisible", value = true})
                        self.menu.wset:MenuElement({id = "stopwult", name = "Stop if R", value = false})
                        self.menu.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
                        self.menu.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
                self.menu:MenuElement({name = "E settings", id = "eset", type = MENU })
                        self.menu.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
                        self.menu.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
                        self.menu.eset:MenuElement({id = "killsteal", name = "Use E KS", value = true})
                        self.menu.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
                        self.menu.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
        end
        
        function __gsoTwitch:CreateDrawMenu()
                  _G.gsoSDK.Menu.gsodraw:MenuElement({name = "Q Timer",  id = "qtimer", type = MENU})
                          _G.gsoSDK.Menu.gsodraw.qtimer:MenuElement({id = "enabled", name = "Enabled", value = true})
                          _G.gsoSDK.Menu.gsodraw.qtimer:MenuElement({id = "color", name = "Color ", color = Draw.Color(200, 65, 255, 100)})
                  _G.gsoSDK.Menu.gsodraw:MenuElement({name = "Q Invisible Range",  id = "qinvisible", type = MENU})
                          _G.gsoSDK.Menu.gsodraw.qinvisible:MenuElement({id = "enabled", name = "Enabled", value = true})
                          _G.gsoSDK.Menu.gsodraw.qinvisible:MenuElement({id = "color", name = "Color ", color = Draw.Color(200, 255, 0, 0)})
                  _G.gsoSDK.Menu.gsodraw:MenuElement({name = "Q Notification Range",  id = "qnotification", type = MENU})
                          _G.gsoSDK.Menu.gsodraw.qnotification:MenuElement({id = "enabled", name = "Enabled", value = true})
                          _G.gsoSDK.Menu.gsodraw.qnotification:MenuElement({id = "color", name = "Color ", color = Draw.Color(200, 188, 77, 26)})
        end
        
        --[[
      gsoOrbwalker:AttackSpeed(function()
        local num = gsoGameTimer() - champInfo.QASEndTime + gsoExtra.maxLatency
        if num > -champInfo.windUpNoQ and num < 2 then
          return champInfo.asNoQ
        end
        return gsoMyHero.attackSpeed
      end)
      --]]
        
        function __gsoTwitch:AddDrawEvent()
                Callback.Add('Draw', function()
                        local lastQ, lastQk, lastW, lastWk, lastE, lastEk, lastR, lastRk = _G.gsoSDK.Spell:GetLastSpellTimers()
                        if Game.Timer() < lastQk + 16 then
                                local pos2D = myHero.pos:To2D()
                                local posX = pos2D.x - 50
                                local posY = pos2D.y
                                local num1 = 1.35-(Game.Timer()-lastQk)
                                local timerEnabled = _G.gsoSDK.Menu.gsodraw.qtimer.enabled:Value()
                                local timerColor = _G.gsoSDK.Menu.gsodraw.qtimer.color:Value()
                                if num1 > 0.001 then
                                        if timerEnabled then
                                                local str1 = tostring(math.floor(num1*1000))
                                                local str2 = ""
                                                for i = 1, #str1 do
                                                        if #str1 <=2 then
                                                                str2 = 0
                                                                break
                                                        end
                                                        local char1 = i <= #str1-2 and str1:sub(i,i) or "0"
                                                        str2 = str2..char1
                                                end
                                                Draw.Text(str2, 50, posX+50, posY-15, timerColor)
                                        end
                                elseif gsoHasQBuff then
                                        local num2 = math.floor(1000*(gsoQBuffDuration-Game.Timer()))
                                        if num2 > 1 then
                                                if _G.gsoSDK.Menu.gsodraw.qinvisible.enabled:Value() then
                                                        Draw.Circle(myHero.pos, 500, 1, _G.gsoSDK.Menu.gsodraw.qinvisible.color:Value())
                                                end
                                                if _G.gsoSDK.Menu.gsodraw.qnotification.enabled:Value() then
                                                        Draw.Circle(myHero.pos, 800, 1, _G.gsoSDK.Menu.gsodraw.qnotification.color:Value())
                                                end
                                                if timerEnabled then
                                                        local str1 = tostring(num2)
                                                        local str2 = ""
                                                        for i = 1, #str1 do
                                                                if #str1 <=2 then
                                                                        str2 = 0
                                                                        break
                                                                end
                                                                local char1 = i <= #str1-2 and str1:sub(i,i) or "0"
                                                                str2 = str2..char1
                                                        end
                                                        Draw.Text(str2, 50, posX+50, posY-15, timerColor)
                                                end
                                        end
                                end
                        end
                end)
        end
        
        function __gsoTwitch:AddTickEvent()
                Callback.Add('Tick', function()
                        --[[q buff best orbwalker dps
                        if gsoGetTickCount() - gsoSpellTimers.lqk < 500 and gsoGetTickCount() > champInfo.lastASCheck + 1000 then
                                champInfo.asNoQ = gsoMyHero.attackSpeed
                                champInfo.windUpNoQ = gsoTimers.windUpTime
                                champInfo.lastASCheck = gsoGetTickCount()
                        end--]]
                        --[[disable attack
                        local num = 1150 - (gsoGetTickCount() - (gsoSpellTimers.lqk + (gsoExtra.maxLatency*1000)))
                        if num < (gsoTimers.windUpTime*1000)+50 and num > - 50 then
                                return false
                        end--]]
                        --qrecall
                        local lastQ, lastQk, lastW, lastWk, lastE, lastEk, lastR, lastRk = _G.gsoSDK.Spell:GetLastSpellTimers()
                        if self.menu.qset.recallkey:Value() == gsoRecall then
                                Control.KeyDown(HK_Q)
                                Control.KeyUp(HK_Q)
                                Control.KeyDown(string.byte("B"))
                                Control.KeyUp(string.byte("B"))
                                gsoRecall = not gsoRecall
                        end
                        --qbuff
                        local qDuration = _G.gsoSDK.Spell:GetBuffDuration(myHero, "globalcamouflage")--twitchhideinshadows
                        gsoHasQBuff = qDuration > 0
                        gsoQBuffDuration = qDuration > 0 and Game.Timer() + qDuration or 0
                        --qasbuff
                        local qasDuration = _G.gsoSDK.Spell:GetBuffDuration(myHero, "twitchhideinshadowsbuff")
                        gsoHasQASBuff = qasDuration > 0
                        gsoQASBuffDuration = qasDuration > 0 and Game.Timer() + qasDuration or 0
                        --handle e buffs
                        local enemyList = _G.gsoSDK.ObjectManager:GetEnemyHeroes(1200, false, "spell")
                        for i = 1, #enemyList do
                                local hero  = enemyList[i]
                                local nID   = hero.networkID
                                if not gsoEBuffs[nID] then
                                        gsoEBuffs[nID] = { count = 0, durT = 0 }
                                end
                                if not hero.dead then
                                        local hasB = false
                                        local cB = gsoEBuffs[nID].count
                                        local dB = gsoEBuffs[nID].durT
                                        for i = 0, hero.buffCount do
                                                local buff = hero:GetBuff(i)
                                                if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                                                        hasB = true
                                                        if cB < 6 and buff.duration > dB then
                                                                gsoEBuffs[nID].count = cB + 1
                                                                gsoEBuffs[nID].durT = buff.duration
                                                        else
                                                                gsoEBuffs[nID].durT = buff.duration
                                                        end
                                                        break
                                                end
                                        end
                                        if not hasB then
                                                gsoEBuffs[nID].count = 0
                                                gsoEBuffs[nID].durT = 0
                                        end
                                end
                        end
                        -- Combo / Harass
                        if not _G.gsoSDK.Orbwalker:UOL_CanMove() or _G.gsoSDK.Orbwalker:UOL_IsAttacking() then
                                return
                        end
                        --EKS
                        if self.menu.eset.killsteal:Value() and _G.gsoSDK.Spell:IsReady(_E, { q = 0, w = 0.25, e = 0.5, r = 0 } ) then
                                for i = 1, #enemyList do
                                        local hero = enemyList[i]
                                        local buffCount = gsoEBuffs[hero.networkID] and gsoEBuffs[hero.networkID].count or 0
                                        if buffCount > 0 and myHero.pos:DistanceTo(hero.pos) < 1200 - 35 then
                                                local elvl = myHero:GetSpellData(_E).level
                                                local basedmg = 10 + ( elvl * 10 )
                                                local perstack = ( 10 + (5*elvl) ) * buffCount
                                                local bonusAD = myHero.bonusDamage * 0.25 * buffCount
                                                local bonusAP = myHero.ap * 0.2 * buffCount
                                                local edmg = basedmg + perstack + bonusAD + bonusAP
                                                if _G.gsoSDK.Spell:GetDamage(hero, { dmgType = "ad", dmgAD = edmg }) >= hero.health + (1.5*hero.hpRegen) and _G.gsoSDK.Spell:CastSpell(HK_E) then
                                                        break
                                                end
                                        end
                                end
                        end
                        local isCombo = _G.gsoSDK.Menu.orb.keys.combo:Value()
                        local isHarass = _G.gsoSDK.Menu.orb.keys.harass:Value()
                        if isCombo or isHarass then
                                local target = _G.gsoSDK.TS:GetComboTarget()
                                if target and _G.gsoSDK.Orbwalker:UOL_CanAttack() then
                                        return
                                end
                                --W
                                local isComboW = _G.gsoSDK.Menu.orb.keys.combo:Value() and self.menu.wset.combo:Value()
                                local isHarassW = _G.gsoSDK.Menu.orb.keys.harass:Value() and self.menu.wset.harass:Value()
                                local isKeyW = isComboW or isHarassW
                                local stopWIfR = self.menu.wset.stopwult:Value() and Game.Timer() < lastRk + 5.45
                                local stopWIfQ = self.menu.wset.stopq:Value() and gsoHasQBuff
                                if isKeyW and not stopWIfR and not stopWIfQ and _G.gsoSDK.Spell:IsReady(_W, { q = 0, w = 0.5, e = 0.25, r = 0 } ) then
                                        if target then
                                                WTarget = target
                                        else
                                                WTarget = _G.gsoSDK.TS:GetTarget(_G.gsoSDK.ObjectManager:GetEnemyHeroes(950, false, "spell"), false)
                                        end
                                        local HitChance, CastPos = _G.gsoSDK.Prediction:UPL_GetPrediction(WTarget, self.wData.delay, self.wData.radius, self.wData.range, self.wData.speed, myHero, self.wData.collision, self.wData.sType)
                                        if HitChance > 0 and _G.gsoSDK.Spell:CastSpell(HK_W, CastPos) then
                                                return
                                        end
                                end
                                --E
                                local isComboE = _G.gsoSDK.Menu.orb.keys.combo:Value() and self.menu.eset.combo:Value()
                                local isHarassE = _G.gsoSDK.Menu.orb.keys.harass:Value() and self.menu.eset.harass:Value()
                                local isKeyE = isComboE or isHarassE
                                if isKeyE and _G.gsoSDK.Spell:IsReady(_E, { q = 0, w = 0.25, e = 0.5, r = 0 } ) then
                                        local countE = 0
                                        local xStacks = self.menu.eset.stacks:Value()
                                        local enemyList = _G.gsoSDK.ObjectManager:GetEnemyHeroes(1200, false, "spell")
                                        for i = 1, #enemyList do
                                                local hero = enemyList[i]
                                                local buffCount = gsoEBuffs[hero.networkID] and gsoEBuffs[hero.networkID].count or 0
                                                if hero and myHero.pos:DistanceTo(hero.pos) < 1200 - 35 and buffCount >= xStacks then
                                                        countE = countE + 1
                                                end
                                        end
                                        if countE >= self.menu.eset.enemies:Value() and _G.gsoSDK.Spell:CastSpell(HK_E) then
                                                return
                                        end
                                end
                        end
                end)
        end
        
__gsoTwitch()