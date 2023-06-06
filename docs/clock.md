# Clock

Calls a function on consistent intervals.

```lua
(
	Interval: number,
	Callback: () -> ()
) -> () -> ()
```

This function will call the given callback every `Interval` seconds. It returns a function that can be called to stop the clock.

```lua
local Stop = Clock(1, function()
	print("Hello!")
end)

-- Prints "Hello!" every second for 5 seconds
task.wait(5)
Stop()
```
