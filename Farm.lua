
local gsoActiveAttacks = {}
local gsoShouldWait = false
local gsoShouldWaitTime = 0

local function gsoPredPos(speed, pPos, unit)
        if unit.pathing.hasMovePath then
                local uPos = unit.pos
                local ePos = unit.pathing.endPos
                local distUP = pPos:DistanceTo(uPos)
                local distEP = pPos:DistanceTo(ePos)
                local unitMS = unit.ms
                if distEP > distUP then
                        return uPos:Extended(ePos, 25+(unitMS*(distUP / (speed - unitMS))))
                else
                        return uPos:Extended(ePos, 25+(unitMS*(distUP / (speed + unitMS))))
                end
        end
        return unit.pos
end

local function gsoUpdateActiveAttacks()
        for k1, v1 in pairs(gsoActiveAttacks) do
                local count = 0
                for k2, v2 in pairs(gsoActiveAttacks[k1]) do
                        count = count + 1
                        if v2.Speed == 0 and (not v2.Ally or v2.Ally.dead) then
                                gsoActiveAttacks[k1] = nil
                                break
                        end
                        if not v2.Canceled then
                                local ranged = v2.Speed > 0
                                if ranged then
                                        gsoActiveAttacks[k1][k2].FlyTime = gsoDistance(v2.Ally.pos, gsoPredPos(v2.Speed, v2.Pos, v2.Enemy)) / v2.Speed
                                end
                                local projectileOnEnemy = 0.025 + _G.gsoSDK.Utilities:GetMaxLatency()
                                if Game.Timer() > v2.StartTime + gsoActiveAttacks[k1][k2].FlyTime - projectileOnEnemy or not v2.Enemy or v2.Enemy.dead then
                                        gsoActiveAttacks[k1][k2] = nil
                                elseif ranged then
                                        gsoActiveAttacks[k1][k2].Pos = v2.Ally.pos:Extended(v2.Enemy.pos, ( Game.Timer() - v2.StartTime ) * v2.Speed)
                                end
                        end
                end
                if count == 0 then
                        gsoActiveAttacks[k1] = nil
                end
        end
end

class "__gsoFarm"

        function __gsoFarm:SetLastHitable(enemyMinion, time, damage, mode, allyMinions)
                if mode == "fast" then
                        local hpPred = self:MinionHpPredFast(enemyMinion, allyMinions, time)
                        local lastHitable = hpPred - damage < 0
                        local almostLastHitable = lastHitable and false or self:MinionHpPredFast(enemyMinion, allyMinions, myHero.attackData.animationTime * 3) - damage < 0
                        if almostLastHitable then
                                gsoShouldWait = true
                                gsoShouldWaitTime = Game.Timer()
                        end
                        return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = enemyMinion }
                elseif mode == "accuracy" then
                        local hpPred = self:MinionHpPredAccuracy(enemyMinion, time)
                        local lastHitable = hpPred - damage < 0
                        local almostLastHitable = lastHitable and false or self:MinionHpPredFast(enemyMinion, allyMinions, myHero.attackData.animationTime * 3) - damage < 0
                        if almostLastHitable then
                                gsoShouldWait = true
                                gsoShouldWaitTime = Game.Timer()
                        end
                        return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = enemyMinion }
                end
        end
        
        function __gsoFarm:CanLaneClear()
                  return not gsoShouldWait
        end
        
        function __gsoFarm:MinionHpPredFast(unit, allyMinions, time)
                local unitHandle, unitPos, unitHealth = unit.handle, unit.pos, unit.health
                for i = 1, #allyMinions do
                        local allyMinion = allyMinions[i]
                        if allyMinion.attackData.target == unitHandle then
                                local flyTime = allyMinion.attackData.projectileSpeed > 0 and gsoDistance(allyMinion.Pos, unitPos) / allyMinion.attackData.projectileSpeed or 0
                                local endTime = (allyMinion.attackData.endTime - allyMinion.attackData.animationTime) + flyTime + allyMinion.attackData.windUpTime
                                endTime = endTime > Game.Timer() and endTime or endTime + allyMinion.attackData.animationTime + flyTime
                                while endTime - Game.Timer() < time do
                                        unitHealth = unitHealth - allyMinion.Dmg
                                        endTime = endTime + allyMinion.attackData.animationTime + flyTime
                                end
                                return unitHealth
                        end
                end
                return unitHealth
        end
        
        function __gsoFarm:MinionHpPredAccuracy(unit, time)
                local unitHealth, unitHandle = unit.health, unit.handle
                for allyID, allyActiveAttacks in pairs(gsoFarm.allyActiveAttacks) do
                        for activeAttackID, activeAttack in pairs(gsoFarm.allyActiveAttacks[allyID]) do
                                if not activeAttack.Canceled and unitHandle == activeAttack.Enemy.handle then
                                        local endTime = activeAttack.StartTime + activeAttack.FlyTime
                                        if endTime > Game.Timer() and endTime - Game.Timer() < time then
                                                unitHealth = unitHealth - activeAttack.Dmg
                                        end
                                end
                        end
                end
                return unitHealth
        end
        
        function __gsoFarm:Tick(allyMinions, enemyMinions)
                for i = 1, #allyMinions do
                        local allyMinion = allyMinions[i]
                        if allyMinion.attackData.endTime > Game.Timer() then
                                for j = 1, #enemyMinions do
                                        local enemyMinion = enemyMinions[j]
                                        if enemyMinion.handle == allyMinion.attackData.target then
                                                local flyTime = allyMinion.attackData.projectileSpeed > 0 and allyMinion.pos:DistanceTo(enemyMinion.pos) / allyMinion.attackData.projectileSpeed or 0
                                                if not gsoActiveAttacks[allyMinion.handle] then
                                                        gsoActiveAttacks[allyMinion.handle] = {}
                                                end
                                                if Game.Timer() < (allyMinion.attackData.endTime - allyMinion.attackData.windDownTime) + flyTime then
                                                        if allyMinion.attackData.projectileSpeed > 0 then
                                                                if Game.Timer() > allyMinion.attackData.endTime - allyMinion.attackData.windDownTime then
                                                                        if not gsoActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] then
                                                                                gsoActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] = {
                                                                                        Canceled = false,
                                                                                        Speed = allyMinion.attackData.projectileSpeed,
                                                                                        StartTime = allyMinion.attackData.endTime - allyMinion.attackData.windDownTime,
                                                                                        FlyTime = flyTime,
                                                                                        Pos = allyMinion.pos:Extended(enemyMinion.pos, allyMinion.attackData.projectileSpeed * ( Game.Timer() - ( allyMinion.attackData.endTime - allyMinion.attackData.windDownTime ) ) ),
                                                                                        Ally = allyMinion,
                                                                                        Enemy = enemyMinion,
                                                                                        Dmg = (allyMinion.totalDamage*(1+allyMinion.bonusDamagePercent))-enemyMinion.flatDamageReduction
                                                                                }
                                                                        end
                                                                elseif allyMinion.pathing.hasMovePath then
                                                                        gsoFarm.allyActiveAttacks[allyMinion.Handle][allyMinion.attackData.endTime] = {
                                                                                Canceled = true,
                                                                                Ally = allyMinion
                                                                        }
                                                                end
                                                        elseif not gsoActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] then
                                                                gsoActiveAttacks[allyMinion.handle][allyMinion.attackData.endTime] = {
                                                                        Canceled = false,
                                                                        Speed = allyMinion.attackData.projectileSpeed,
                                                                        StartTime = (allyMinion.attackData.endTime - allyMinion.attackData.windDownTime) - allyMinion.attackData.windUpTime,
                                                                        FlyTime = allyMinion.attackData.windUpTime,
                                                                        Pos = allyMinion.pos,
                                                                        Ally = allyMinion,
                                                                        Enemy = enemyMinion,
                                                                        Dmg = (allyMinion.totalDamage*(1+allyMinion.bonusDamagePercent))-enemyMinion.flatDamageReduction
                                                                }
                                                        end
                                                end
                                                break
                                        end
                                end
                        end
                end
                gsoUpdateActiveAttacks()
                if gsoShouldWait and Game.Timer() > gsoShouldWaitTime + 0.5 then
                        gsoShouldWait = false
                end
        end











--[[
        function __gsoFarm:UpdateMinions(enemyMinions)
                if gsoShouldWait and gsoGameTimer() > gsoShouldWaitT + 0.5 then
                  gsoShouldWait = false
                end
                local mLH, aaData, projSpeed, windUp, anim, meDmg
                if #enemyMinionsCache > 0 then
                  mLH = gsoMenu.orb.delays.lhDelay:Value() * 0.001
                  aaData = gsoMyHero.attackData
                  projSpeed = aaData.projectileSpeed
                  windUp = aaData.windUpTime - mLH
                  windUp = windUp + (gsoExtra.minLatency*0.5)
                  anim = aaData.animationTime
                  meDmg = myHero.totalDamage
                end
                local lastHitable = {}
                local almostLastHitable = {}
                local laneClearable = {}
                for i = 1, #enemyMinionsCache do
                  local enemy = enemyMinionsCache[i]
                  local minionHandle = enemy.Handle
                  local minionPos = enemy.Pos
                  local minionHealth = enemy.Health
                  local flyTime = windUp + ( gsoDistance(mePos, minionPos) / projSpeed )
                  local accuracyHpPred = gsoMinionHpPredAccuracy(minionHealth, minionHandle, flyTime)
                  if accuracyHpPred - meDmg <= 0 then
                    lastHitable[#lastHitable+1] = { Minion = enemy.Minion, pos = minionPos, health = accuracyHpPred }
                  else
                    if gsoMinionHpPredFast(minionHandle, minionPos, minionHealth, anim*3, allyMinionsCache, enemyHandles) - meDmg < 0 then
                      almostLastHitable[#almostLastHitable+1] = enemy.Minion
                    else
                      laneClearable[#laneClearable+1] = { Minion = enemy.Minion, pos = minionPos, health = accuracyHpPred }
                    end
                  end
                end
                gsoFarm.lastHitable = lastHitable
                gsoFarm.laneClearable = laneClearable
                gsoFarm.almostLastHitable = almostLastHitable
        end
        
local function minionsLogic()
    
    if gsoShouldWait and gsoGameTimer() > gsoShouldWaitT + 0.5 then
        gsoShouldWait = false
    end
    
    local sourcePos, sourceRange, mLH, aaData, windUp, meDmg
    local enemyMinions = gsoGetEnemyMinions(2000, gsoMyHero.pos, false)
    if #enemyMinions > 0 then
        sourcePos = gsoMyHero.pos
        sourceRange = gsoMyHero.range + gsoMyHero.boundingRadius
        mLH = gsoMenu.orb.delays.lhDelay:Value() * 0.001
        aaData = gsoMyHero.attackData
        windUp = aaData.windUpTime + gsoExtra.minLatency - mLH
        meDmg = myHero.totalDamage + gsoBonusDmg()
    end
    
    local lastHitable = {}
    local almostLastHitable = {}
    local laneClearable = {}
    for i = 1, #enemyMinions do
        local minion = enemyMinions[i]
        local flyTime = windUp + ( gsoDistance(sourcePos, minion.pos) / aaData.projectileSpeed )
        local accuracyHpPred = gsoMinionHpPredAccuracy(minion, flyTime)
        local hpPred = gsoMenu.orb.farmmode:Value() == 1 and accuracyHpPred or gsoMinionHpPredFast(minion, flyTime)
        local dmgOnMinion = meDmg + gsoBonusDmgUnit(minion)
        if accuracyHpPred < 0 then
            local args = { Minion = minion }
            for i = 1, #gsoUnkillableMinion do
                local action = gsoUnkillableMinion[i](args)
            end
            --print("unkillable")
        end
        if hpPred - dmgOnMinion <= 0 then
            lastHitable[#lastHitable+1] = { Minion = minion, Health = hpPred }
        else
            local fastHpPred = gsoMinionHpPredFast(minion, aaData.animationTime * 3)
            if fastHpPred - dmgOnMinion < 0 then
                gsoShouldWait = true
                gsoShouldWaitT = gsoGameTimer()
                almostLastHitable[#almostLastHitable+1] = { Minion = minion, Health = hpPred }
            else
                laneClearable[#laneClearable+1] = { Minion = minion, Health = hpPred }
            end
        end
    end
    
    gsoFarm.lastHitable = lastHitable
    gsoFarm.laneClearable = laneClearable
    gsoFarm.almostLastHitable = almostLastHitable
    
end
--]]