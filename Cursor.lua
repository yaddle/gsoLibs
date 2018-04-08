local gsoCursorReady = true
local gsoExtraSetCursor = nil
local gsoSetCursorPos = nil

class "__gsoCursor"
        
        function __gsoCursor:IsCursorReady()
                return gsoCursorReady
        end
        
        function __gsoCursor:SetCursor(cPos, castPos, delay)
                gsoExtraSetCursor = castPos
                gsoCursorReady = false
                gsoSetCursorPos = { EndTime = Game.Timer() + delay, Action = function() Control.SetCursorPos(cPos.x, cPos.y) end, Active = true }
        end
        
        function __gsoCursor:Tick()
                if gsoSetCursorPos then
                        if gsoSetCursorPos.Active and Game.Timer() > gsoSetCursorPos.EndTime then
                                gsoSetCursorPos.Action()
                                gsoSetCursorPos.Active = false
                                gsoExtraSetCursor = nil
                        elseif not gsoSetCursorPos.Active and Game.Timer() > gsoSetCursorPos.EndTime + 25 then
                                gsoCursorReady = true
                                gsoSetCursorPos = nil
                        end
                end
                if gsoExtraSetCursor then
                        Control.SetCursorPos(gsoExtraSetCursor)
                end
        end