-- // MODULES //
local Scheduler = require(script.Parent).Module
local TimedFunction = require(script.Parent.TimedFunction).TimedFunction

-- // MAIN FUNCTIONS //
local function insert(tail, node)
	if tail then
		local compare = tail
		while compare do
			-- // behind ( [0]=([1])=[2]=[3] )
			if node.item.expectedResumeTime <= compare.item.expectedResumeTime then
				if compare.previous then
					node.previous = compare.previous
					compare.previous.next = node
				else
					tail = node
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
		tail = node
	end
	return tail
end

function Scheduler:ScheduleEvery(t, func)
    local timed = TimedFunction.new(t, func, self)
    local node = {
		next = nil,
		previous = nil,
		item = timed
	}

	local function insertIntoNode()
		local tail = self._timed
		
		self._timed = insert(tail, node)
	end

	if self.DoneResuming then
		table.insert(self.DoneResuming, insertIntoNode)
	else
		insertIntoNode()
	end
	

    return timed
end

function Scheduler:_stopTimedFunction(timed)
    local tail = self._timed
	local node = tail
	while node do
		if node.item == timed then
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
			self._timed = tail
		end
	else
        warn(tostring(timed) .. " is not timed!\n" .. (debug.traceback(nil, 3) or ''))
    end
end

function Scheduler:StopTimedFunction(timed)
	if self.resuming then
		table.insert(self.DoneResuming, function()
			self:_stopTimedFunction(timed)
		end)
	else
		self:_stopTimedFunction(timed)
	end
end

function Scheduler:_timedUpdate(currentTime)
	debug.profilebegin(string.format('TimedScheduler[%s]', self.name))
	self.resuming = true
	self.DoneResuming = {}
    local tail = self._timed
	local resumed = {}
	local timed = tail
	while timed do
		if timed.item:PastOrEqualResumeTime(currentTime) then
			if not timed.item.stopped then
				timed.item:Resume(currentTime)
				if not timed.item.stopped then
					if timed.next then
						timed.next.previous = timed.previous
					end
					if timed.previous then
						timed.previous.next = timed.next
					else
						tail = timed.next
						if tail then
							tail.previous = nil
						end
						self._timed = tail
					end
					table.insert(resumed, timed)
				end
			end
		else
			break
		end
		timed = timed.next
	end
	for _, node in ipairs(resumed) do
		node.next = nil
		node.previous = nil
		if not node.item.stopped then
			self._timed = insert(self._timed, node)
		end
	end
    debug.profileend()
	for _, f in ipairs(self.DoneResuming) do
		f()
	end
	self.DoneResuming = nil
	self.resuming = false
end

return {Scheduler = Scheduler}