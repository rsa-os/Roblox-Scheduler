-- // RE-DEFINITIONS //
local clock = os.clock

-- // MODULES //
local Scheduler

-- // CLASS //
local TimedFunction = {}
local TimedFunctionClass = {}
TimedFunctionClass.__index = TimedFunctionClass


-- // CONSTRUCTOR //
function TimedFunction.new(t, func)
	local timedOn = clock()
	local timed = setmetatable(
		{
			expectedResumeTime = timedOn + t,
			requestedWaitTime = t,
			func = func,
			scheduledTime = timedOn,
			stopped = false
		},
		TimedFunctionClass
	)

	return timed
end

-- // METHODS //
function TimedFunctionClass:PastOrEqualResumeTime(t)
	return self.expectedResumeTime <= t
end

function TimedFunctionClass:Resume(currentTime)
	if self.stopped then
		error("Attempt to resume a stopped TimedFunction", 2)
    end
	local extra = currentTime - self.expectedResumeTime
    local nextExpectedResumeTime = currentTime + self.requestedWaitTime - extra

    local success, err = coroutine.resume(coroutine.create(self.func), currentTime - self.scheduledTime)

	if not success then
		warn(tostring(self) .. " failed to resume")
		warn(err)
	end

	self.expectedResumeTime = nextExpectedResumeTime
	self.scheduledTime = currentTime
end

function TimedFunctionClass:Stop()
    self.stopped = true
    Scheduler:StopTimedFunction(self)
end

TimedFunctionClass.Destroy = TimedFunctionClass.Stop

-- // META-METHODS //
function TimedFunctionClass:__tostring()
	return
		("TimedFunction {ExpectedResumeTime: %.04f, RequestedWaitTime: %.04f,"
		.. " ScheduledTime: %.04f"
		):format(self.expectedResumeTime, self.requestedWaitTime, self.scheduledTime)
end


-- // INIT //
function TimedFunction:Init()
    self.Init = nil
    Scheduler = require(script.Parent).Scheduler
end

return {TimedFunction = TimedFunction}
