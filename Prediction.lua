local myHero = myHero

-- NODDY PRED START
local function IsImmobileTarget(unit)
        for i = 0, unit.buffCount do
                local buff = unit:GetBuff(i)
                if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
                        return true
                end
        end
        return false
end
local _OnVision = {}
local visionTick = GetTickCount()
local function OnVision(unit)
        if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
        if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
        if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
        return _OnVision[unit.networkID]
end
local _OnWaypoint = {}
local function OnWaypoint(unit)
        if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
        if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
                _OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
                DelayAction(function()
                        local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
                        local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
                        if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
                                _OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
                        end
                end, 0.05)
        end
        return _OnWaypoint[unit.networkID]
end
Callback.Add("Tick", function()
        if GetTickCount() - visionTick > 100 then
                for i,v in pairs(GetEnemyHeroes()) do
                        OnVision(v)
                end
        end
        local enemies = _G.gsoSDK.ObjectManager:GetEnemyHeroes(math.huge, false, "spell")
        for i = 1, #enemies do
                OnWaypoint(enemies[i])
        end
end)
local function GetPred(unit,speed,delay)
        speed = speed or math.huge
        delay = delay or 0.25
        local unitSpeed = unit.ms
        if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
        if OnVision(unit).state == false then
                local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
                local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
                if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
                return predPos
        else
                if unitSpeed > unit.ms then
                        local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
                        if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
                        return predPos
                elseif IsImmobileTarget(unit) then
                        return unit.pos
                else
                        return unit:GetPrediction(speed,delay)
                end
        end
end
-- NODDY PRED END

class "__gsoPrediction"
        
        function __gsoPrediction:UPL_GetPred(unit, speed, delay)
                --[[if menu == 1 then (noddy)
                        return GetPred(unit,speed,delay)
                elseif
                end--]]
        end