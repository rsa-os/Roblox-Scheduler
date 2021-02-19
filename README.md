# Roblox-Scheduler
A really simple scheduler.

Setting up
```lua
local Scheduler = require(game.ReplicatedStorage.Scheduler).Scheduler
Scheduler:Init()
```

Fast scheduling
```lua
local deltaTime = Scheduler:FastSchedule(1)
print(deltaTime)
```

Manual scheduling
```lua
local scheduledObject = Scheduler:Schedule(1, coroutine.create(function(deltaTime)
  print(deltaTime)
end)
-- can cancel it if you feel like it
scheduledObject:Cancel()
```

Timed scheduling
```lua
local timed = Scheduler:ScheduleEvery(1, function(deltaTime)
  print(deltaTime)
end)
-- can also be stopped
timed:Stop()
```
