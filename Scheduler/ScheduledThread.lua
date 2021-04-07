-- // RE-DEFINITIONS //
local clock = os.clock

-- // MODULES//
local Scheduler = require(script.Parent).Scheduler

-- // CLASS //
local ScheduledThread = {}
local ScheduledThreadClass = {}
ScheduledThreadClass.__index = ScheduledThreadClass

-- // CONSTRUCTOR //
function ScheduledThread.new(t, thread)
	local scheduledTime = clock()
	local scheduled = setmetatable(
		{
			expectedResumeTime = scheduledTime + t,
			requestedWaitTime = t,
			thread = thread,
			scheduledTime = scheduledTime,
			resumed = false
		},
		ScheduledThreadClass
	)

	return scheduled
end

-- // METHODS //
function ScheduledThreadClass:PastOrEqualResumeTime(t)
	return self.expectedResumeTime <= t
end

function ScheduledThreadClass:Resume(currentTime)
	if self.resumed then
		error("Attempt to resume an already resumed thread", 2)
	end

	self.resumed = true
	local success, err = coroutine.resume(self.thread, currentTime - self.scheduledTime)

	if not success then
		warn(tostring(self) .. ' failed to resume. Error: ' .. tostring(err))
	end
end

function ScheduledThreadClass:Cancel()
	Scheduler:Cancel(self)
end

-- // META-METHODS //
function ScheduledThreadClass:__tostring()
	return
		("ScheduledThread {ExpectedResumeTime: %.04f, RequestedWaitTime: %.04f,"
		.. " ScheduledTime: %.04f}"
		):format(self.expectedResumeTime, self.requestedWaitTime, self.scheduledTime)
end

return {ScheduledThread = ScheduledThread}