-- // RE-DEFINITIONS //
local clock = os.clock

-- // CLASS //
local ScheduledThread = {}
local ScheduledThreadClass = {}
ScheduledThreadClass.__index = ScheduledThreadClass

-- // CONSTRUCTOR //
function ScheduledThread.new(t, thread, scheduler)
	local scheduledTime = clock()
	local scheduled = setmetatable(
		{
			expectedResumeTime = scheduledTime + t,
			requestedWaitTime = t,
			thread = thread,
			scheduledTime = scheduledTime,
			resumed = false,
			scheduler = scheduler
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
		error(tostring(self) .. "\nAttempt to resume an already resumed thread", 2)
	end

	self.resumed = true
	local success, err = coroutine.resume(self.thread, currentTime - self.scheduledTime)

	if not success then
		warn(tostring(self) .. '\nfailed to resume. Error: ' .. tostring(err))
	end
end

function ScheduledThreadClass:ResumeNow(currentTime)
	currentTime = currentTime or os.clock()

	self:Resume(currentTime)
end

function ScheduledThreadClass:Cancel()
	self.scheduler:Cancel(self)
end

ScheduledThreadClass.Destroy = ScheduledThreadClass.Cancel

-- // META-METHODS //
function ScheduledThreadClass:__tostring()
	return
		("ScheduledThread[%s] {ExpectedResumeTime: %.04f, RequestedWaitTime: %.04f,"
		.. " ScheduledTime: %.04f}"
		):format(self.scheduler.name, self.expectedResumeTime, self.requestedWaitTime, self.scheduledTime)
end

return {ScheduledThread = ScheduledThread}