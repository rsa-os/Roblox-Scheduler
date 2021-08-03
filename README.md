# Roblox-Scheduler
A really simple scheduler.

## Installation
### For use in a rojo-like setup:
```
git clone https://github.com/Kisty1/Roblox-Scheduler/
mv Roblox-Scheduler/Scheduler dir-you-want-to-copy-it-to
rm -rf Roblox-Scheduler
```
### For use in a Roblox Studio setup: 
Download the latest release from [releases](https://github.com/Kisty1/Roblox-Scheduler/releases) and drag/drop into an opened place in Roblox Studio

## Usage

### Setting up
```lua
local Scheduler = require(game.ReplicatedStorage.Scheduler).Scheduler
Scheduler:Init()
```

### Fast scheduling
```lua
local deltaTime = Scheduler:FastSchedule(1)
print(deltaTime)
```

### Manual scheduling
```lua
local scheduledObject = Scheduler:Schedule(1, coroutine.create(function(deltaTime)
  print(deltaTime)
end)
-- can cancel it if you feel like it
scheduledObject:Cancel()
```

### Timed scheduling
```lua
local timed = Scheduler:ScheduleEvery(1, function(deltaTime)
  print(deltaTime)
end)
-- can also be stopped
timed:Stop()
```

Both ScheduledObject and TimedObject have a .Destroy alias, so they can be safely used with maids

### Seperated scheduler
```lua
local Scheduler = require(game.ReplicatedStorage.Scheduler).Scheduler.newScheduler('name_here')
-- use the scheduler
```
This will use the given name for profiling in the microprofiler
