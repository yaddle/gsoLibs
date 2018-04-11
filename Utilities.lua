local gsoMinLatency = Game.Latency() * 0.001
local gsoMaxLatency = Game.Latency() * 0.001
local gsoMin = Game.Latency() * 0.001
local gsoLAT = {}
local gsoDA = {}

local function gsoDelayedActions()
        local cacheDA = {}
        for i = 1, #gsoDA do
                local t = gsoDA[i]
                if Game.Timer() > t.StartTime + t.Delay then
                        t.Func()
                else
                        cacheDA[#cacheDA+1] = t
                end
        end
        gsoDA = cacheDA
end

local function gsoLatencies()
        local lat1 = 0
        local lat2 = 50
        local latency = Game.Latency() * 0.001
        if latency < gsoMin then
                gsoMin = latency
        end
        gsoLAT[#gsoLAT+1] = { endTime = Game.Timer() + 1.5, Latency = latency }
        local cacheLatencies = {}
        for i = 1, #gsoLAT do
                local t = gsoLAT[i]
                if Game.Timer() < t.endTime then
                        cacheLatencies[#cacheLatencies+1] = t
                        if t.Latency > lat1 then
                                lat1 = t.Latency
                                gsoMaxLatency = lat1
                        end
                        if t.Latency < lat2 then
                                lat2 = t.Latency
                                gsoMinLatency = lat2
                        end
                end
        end
        gsoLAT = cacheLatencies
end

class "__gsoUtilities"
        
        function __gsoUtilities:Tick()
                gsoDelayedActions()
                gsoLatencies()
        end
        
        function __gsoUtilities:AddAction(func, delay)
                gsoDA[#gsoDA+1] = { StartTime = Game.Timer(), Func = func, Delay = delay }
        end
        
        function __gsoUtilities:GetMaxLatency()
                return gsoMaxLatency
        end
        
        function __gsoUtilities:GetMinLatency()
                return gsoMinLatency
        end
        
        function __gsoUtilities:GetUserLatency()
                return gsoMin
        end