local gsoCursorReady = true
local gsoExtraSetCursor = nil
local gsoSetCursorPos = nil
local gsoDrawMenu = nil

class "__gsoCursor"
        
        function __gsoCursor:IsCursorReady()
                return gsoCursorReady
        end
        
        function __gsoCursor:CreateDrawMenu(menu)
                gsoDrawMenu = menu:MenuElement({name = "Cursor Pos",  id = "cursor", type = MENU})
                        gsoDrawMenu:MenuElement({name = "Enabled",  id = "enabled", value = true})
                        gsoDrawMenu:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 204, 0, 0)})
                        gsoDrawMenu:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                        gsoDrawMenu:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
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
                        elseif not gsoSetCursorPos.Active and Game.Timer() > gsoSetCursorPos.EndTime + 0.025 then
                                gsoCursorReady = true
                                gsoSetCursorPos = nil
                        end
                end
                if gsoExtraSetCursor then
                        Control.SetCursorPos(gsoExtraSetCursor)
                end
        end
        
        function __gsoCursor:Draw()
                if gsoDrawMenu.enabled:Value() then
                        Draw.Circle(mousePos, gsoDrawMenu.radius:Value(), gsoDrawMenu.width:Value(), gsoDrawMenu.color:Value())
                end
        end