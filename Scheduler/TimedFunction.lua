-- // RE-DEFINITIONS //
local clock = os.clock

-- // CLASS //
local TimedFunction = {}
local TimedFunctionClass = {}
TimedFunctionClass.__index = TimedFunctionClass


-- // CONSTRUCTOR //
function TimedFunction.new(t, func, scheduler)
	local timedOn = clock()
	local timed = setmetatable(
		{
			expectedResumeTime = timedOn + t,
			requestedWaitTime = t,
			func = func,
			scheduledTime = timedOn,
			stopped = false,
			scheduler = scheduler
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
		print(self.scheduler)
		error(tostring(self) .. "\nAttempt to resume a stopped TimedFunction", 2)
    end
	local extra = currentTime - self.expectedResumeTime
    local nextExpectedResumeTime = currentTime + self.requestedWaitTime - extra

    local success, err = coroutine.resume(coroutine.create(self.func), currentTime - self.scheduledTime)

	if not success then
		warn(tostring(self) .. "\nfailed to resume")
		warn(err)
	end

	if not self.stopped then
		self.expectedResumeTime = nextExpectedResumeTime
		self.scheduledTime = currentTime
	end
end

function TimedFunctionClass:Stop()
	if not self.stopped then
		self.stopped = true
		self.scheduler:StopTimedFunction(self)
	else
		warn(tostring(self) .. '\nis not timed!\n' .. (debug.traceback(nil, 2) or ''))
	end
end

function TimedFunctionClass:IsStopped()
	return self.stopped
end

TimedFunctionClass.Destroy = TimedFunctionClass.Stop

-- // META-METHODS //
function TimedFunctionClass:__tostring()
	return
		("TimedFunction[%s] {ExpectedResumeTime: %.04f, RequestedWaitTime: %.04f,"
		.. " ScheduledTime: %.04f, Stopped: %s}"
		):format(self.scheduler.name, self.expectedResumeTime, self.requestedWaitTime, self.scheduledTime, tostring(self.stopped))
end

return {TimedFunction = TimedFunction}
