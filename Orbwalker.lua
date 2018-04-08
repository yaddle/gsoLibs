local gsoIsTeemo = false
local gsoIsBlindedByTeemo = false
local gsoLastAttack = 0

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
                _G.gsoSDK.ObjectManager:OnEnemyHeroLoad(function(hero) if hero.charName == "Teemo" then gsoIsTeemo = true end end)
        end
        
        function __gsoOrbwalker:Tick()
                if gsoIsTeemo then gsoIsBlindedByTeemo = gsoCheckTeemoBlind() end
        end
        
        function __gsoOrbwalker:WndMsg(msg, wParam)
                if wParam == HK_TCO then
                        gsoLastAttack = Game.Timer()
                end
        end


--[[
local function gsoOrbwalkerTimersLogic()
  local aSpell = gsoMyHero.activeSpell
  if aSpell and aSpell.valid and aSpell.startTime > gsoServerStart then
    local aSpellName = aSpell.name:lower()
    if not gsoNoAttacks[aSpellName] and (aSpellName:find("attack") or gsoAttacks[aSpellName]) then
      gsoServerStart = aSpell.startTime
      gsoServerWindup = aSpell.windup
      gsoServerAnim = aSpell.animation
    end
  end
  local extraWindUp = gsoMenu.orb.delays.windup:Value() * 0.001
  local numAS = gsoMyHero.attackSpeed * gsoBaseAASpeed
  gsoExtra.attackSpeed = numAS
  local animT   = 1 / numAS
  local windUpT = animT * gsoBaseWindUp
  extraWindUp = extraWindUp + math.abs(windUpT-gsoServerWindup)
  local windUpAA = windUpT > gsoServerWindup and gsoServerWindup or windUpT
  gsoTimers.windUpTime = windUpT > gsoServerWindup and windUpT or gsoServerWindup
  gsoTimers.animationTime = animT > gsoServerAnim and animT or gsoServerAnim
  local sToAA = gsoServerStart - windUpAA
        sToAA = sToAA + gsoTimers.animationTime
        sToAA = sToAA - gsoExtra.minLatency
        sToAA = sToAA - 0.05
        sToAA = sToAA - gsoGameTimer()
  local sToMove = gsoServerStart + extraWindUp
        sToMove = sToMove - (gsoExtra.minLatency*0.5)
        sToMove = sToMove - gsoGameTimer()
  local isChatOpen = gsoGameIsChatOpen()
  gsoTimers.secondsToAttack = sToAA > 0 and sToAA or 0
  gsoTimers.secondsToMove = sToMove > 0 and sToMove or 0
  gsoState.isEvading = ExtLibEvade and ExtLibEvade.Evading
  local canMove = gsoGameTimer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.minLatency
  gsoState.canAttack = canMove and not gsoState.isChangingCursorPos and not gsoState.isBlindedByTeemo and not gsoState.isEvading and gsoState.enabledAttack and (gsoTimers.secondsToAttack == 0 or gsoExtra.resetAttack) and not isChatOpen
  gsoState.canMove = canMove and not gsoState.isChangingCursorPos and not gsoState.isEvading and gsoState.enabledMove and gsoTimers.secondsToMove == 0 and not isChatOpen
end

local function gsoAttackMove(unit)
  if ExtLibEvade and ExtLibEvade.Evading then gsoState.isMoving=true;gsoState.isAttacking=false;gsoState.isEvading=true;return;end
  if not unit and gsoState.canAttack and gsoState.canMove then gsoState.canMove = Game.Timer() > gsoTimers.lastAttackSend + gsoTimers.windUpTime + gsoExtra.minLatency + 0.07 end
  if not gsoCanMove() then gsoState.canMove = false end
  if not gsoCanAttack() then gsoState.canAttack = false end
  if unit and gsoState.canAttack then
    gsoState.isMoving = false
    gsoState.isAttacking = true
    gsoExtra.resetAttack = false
    local cPos = cursorPos
    local tPos = unit.pos
    gsoControlSetCursor(tPos)
    gsoExtraSetCursor = tPos
    gsoControlKeyDown(HK_TCO)
    gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
    gsoControlMouseEvent(MOUSEEVENTF_RIGHTUP)
    gsoControlKeyUp(HK_TCO)
    gsoState.isChangingCursorPos = true
    gsoSetCursorPos = { endTime = gsoGetTickCount() + 50, action = function() gsoControlSetCursor(cPos.x, cPos.y) end, active = true }
    gsoTimers.lastMoveSend = 0
    gsoTimers.lastAttackSend = gsoGameTimer()
    gsoExtra.lastTarget = unit
  elseif gsoState.canMove then
    gsoState.isMoving = true
    gsoState.isAttacking = false
    if gsoGameTimer() > gsoTimers.lastMoveSend + ( gsoMenu.orb.delays.humanizer:Value() * 0.001 ) then
      if gsoControlIsKeyDown(2) then gsoLastKey = gsoGetTickCount() end
      gsoExtra.lastMovePos = mousePos
      gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
      gsoControlMouseEvent(MOUSEEVENTF_RIGHTUP)
      gsoTimers.lastMoveSend = gsoGameTimer()
    end
  end
end

local function gsoOrbwalkerLogic()
  gsoObjects.comboTarget = gsoGetTarget(gsoMyHero.range + gsoMyHero.boundingRadius, gsoObjects.enemyHeroes_attack, gsoMyHero.pos, gsoAPDmg, true)
  local isCombo,isHarass,isLastHit,isLaneClear=gsoMenu.orb.keys.combo:Value(),gsoMenu.orb.keys.harass:Value(),gsoMenu.orb.keys.lasthit:Value(),gsoMenu.orb.keys.laneclear:Value()
  if isCombo or isHarass or isLastHit or isLaneClear then
    if gsoBaseAASpeed == 0 then gsoBaseAASpeed=1/gsoMyHero.attackData.animationTime/gsoMyHero.attackSpeed;gsoExtra.baseAttackSpeed=gsoBaseAASpeed;end
    if gsoBaseWindUp == 0 then gsoBaseWindUp=gsoMyHero.attackData.windUpTime/gsoMyHero.attackData.animationTime;gsoExtra.baseWindUp=gsoBaseWindUp;end
    if isCombo == true then
      gsoAttackMove(gsoGetComboTarget())
    elseif isHarass == true then
      gsoAttackMove(gsoGetHarassTarget())
    elseif isLastHit == true then
      gsoAttackMove(gsoGetLastHitTarget())
    elseif isLaneClear == true then
      gsoAttackMove(gsoGetLaneClearTarget())
    end
  else
    gsoState.isMoving = false
    gsoState.isAttacking = false
    if not gsoState.isChangingCursorPos and gsoGetTickCount() < gsoLastKey + 1000 then
      gsoControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
      gsoLastKey = 0
    end
  end
end--]]