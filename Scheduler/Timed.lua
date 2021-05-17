-- // MODULES //
local Scheduler = require(script.Parent).Scheduler
local TimedFunction = require(script.Parent.TimedFunction).TimedFunction

-- // MAIN FUNCTIONS //
function Scheduler:ScheduleEvery(t, func)
    local timed = TimedFunction.new(t, func)
    table.insert(self._timed, timed)
    return timed
end

function Scheduler:StopTimedFunction(timed)
    local index = table.find(self._timed, timed)
    if index then
        table.remove(self._timed, index)
    else
        warn(tostring(timed) .. " is not timed!\n" .. (debug.traceback(nil, 3) or ''))
    end
end

function Scheduler:_timedUpdate(currentTime)
    for _, timed in ipairs(self._timed) do
        if timed:PastOrEqualResumeTime(currentTime) then
            timed:Resume(currentTime)
        end
    end
end

return {Scheduler = Scheduler}