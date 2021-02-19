-- // RE-DEFINITIONS //
local clock = os.clock

-- // MODULES //
local Scheduler = {}

-- // CLASSES //
local ScheduledThread

-- // MAIN FUNCTIONS //
function Scheduler:FastSchedule(t)
	t = t or (1 / 60)
	return coroutine.yield(Scheduler:Schedule(t, coroutine.running()))
end

function Scheduler:Schedule(t, thread)
	local scheduled = ScheduledThread.new(t, thread)
	self._scheduled[#self._scheduled + 1] = scheduled
	return scheduled
end

function Scheduler:Cancel(scheduledThread)
    local index = table.find(self._scheduled, scheduledThread)
    if index then
        table.remove(self._scheduled, index)
    else
        warn(tostring(scheduledThread) .. " is not timed!")
    end
end


function Scheduler:_update(currentTime)
	local removed = 0
	for i = 1, #Scheduler.Scheduled do
		local scheduled = self._scheduled[i - removed]
		if scheduled:PastOrEqualResumeTime(currentTime) then
			table.remove(Scheduler.Scheduled, i - removed)
			removed = removed + 1
			scheduled:Resume(currentTime)
		end
	end
end

function Scheduler:Init()
	self.Init = nil
	self.ModuleName = "Scheduler"
	self._scheduled = { }
	self._timed = { }

	ScheduledThread = require(script.ScheduledThread)
	require(script.Timed)
	require(script.TimedFunction).TimedFunction:Init()

	game:GetService("RunService").Stepped:Connect(
		function()
			self:_update(clock())
			self:_timedUpdate(clock())
		end
	)
end

return {Scheduler = Scheduler}
