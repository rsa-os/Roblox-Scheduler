-- // RE-DEFINITIONS //
local clock = os.clock


-- // CLASSES //
local ScheduledThread

local function count(node)
	local amount = 0
	while node do
		amount += 1
		node = node.next
	end
	return amount
end

local function __tostring(self)
	local scheduledThreads = count(self._scheduled)
	local timedThreads = #self._timed -- count(self._timed)
	return string.format('Scheduler[%s]: {ScheduledThreads: %d, TimedThreads: %d}', self.name, scheduledThreads, timedThreads)
end
-- // MODULES //
local Scheduler = setmetatable({}, {__tostring = __tostring})
Scheduler.__index = Scheduler
Scheduler.__tostring = __tostring

-- // MAIN FUNCTIONS //
function Scheduler.newScheduler(name)
	local self = setmetatable({name = name or '[UNNAMED]', _timed = nil}, Scheduler)
	
	self.SteppedConnection = game:GetService('RunService').Stepped:Connect(function()
		if self._scheduled then
			self:_update(clock())
		end
		if self._timed then
			self:_timedUpdate(clock())
		end
	end)

	return self
end


function Scheduler:Destroy()
	if Scheduler == self then
		error('Cannot destroy main scheduler', 2)
	end

	self._scheduled = nil
	self._timed = nil
	self.SteppedConnection:Disconnect()
	self.SteppedConnection = nil
end

function Scheduler:FastSchedule(t)
	t = t or (1 / 60)
	return coroutine.yield(self:Schedule(t, coroutine.running()))
end

function Scheduler:Schedule(t, thread)
	local scheduled = ScheduledThread.new(t, thread, self)
	local node = {
		next = nil,
		previous = nil,
		item = scheduled
	}

	local tail = self._scheduled
	if tail then
		local compare = tail
		while compare do
			-- // behind ( [0]=([1])=[2]=[3] )
			if scheduled.expectedResumeTime <= compare.item.expectedResumeTime then
				if compare.previous then
					node.previous = compare.previous
					compare.previous.next = node
				else
					tail = node
					self._scheduled = node
				end
				node.next = compare
				compare.previous = node
				break
			-- // end of the node list
			elseif not compare.next then
				compare.next = node
				node.previous = compare
				break
			-- // front ( [0]=[1]=[2]=([3]))
			else
				compare = compare.next
			end
		end
	else
		self._scheduled = node
	end

	return scheduled
end

function Scheduler:Cancel(scheduledThread)
	local tail = self._scheduled
	local node = tail
	while node do
		if node.item == scheduledThread then
			break
		end
		node = node.next
	end

	if node then
		if node.next then
			node.next.previous = node.previous
		end
		if node.previous then
			node.previous.next = node.next
		else
			tail = node.next
			if tail then
				tail.previous = nil
			end
			self._scheduled = tail
		end
	-- else
    --     warn(tostring(scheduledThread) .. " is not scheduled!\n" .. (debug.traceback(nil, 3) or ''))
    end
end


function Scheduler:_update(currentTime)
	debug.profilebegin(string.format('Scheduler[%s]', self.name))
	local tail = self._scheduled
	local scheduled = tail
	while scheduled do
		if scheduled.item:PastOrEqualResumeTime(currentTime) then
			scheduled.item:Resume(currentTime)
			if scheduled.next then
				scheduled.next.previous = scheduled.previous
			end
			if scheduled.previous then
				scheduled.previous.next = scheduled.next
			else
				tail = scheduled.next
				if tail then
					tail.previous = nil
				end
			end
		else
			break
		end
		scheduled = scheduled.next
	end
	self._scheduled = tail
	debug.profileend()
end

function Scheduler:Init()
	self.Init = nil
	self.ModuleName = "Scheduler"
	self._scheduled = nil
	self._timed = nil
	self.name = 'Main'

	ScheduledThread = require(script.ScheduledThread).ScheduledThread
	require(script.Timed)
end

return {Scheduler = Scheduler.newScheduler('Main'), Module = Scheduler}
