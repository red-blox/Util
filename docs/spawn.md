# Spawn

A shared "fast spawn" function that reuses threads.

```lua
<T...>(
	Callback: (T...) -> (),
	...: T...
) -> ()
```

This utility is used to spawn a function in a new thread. It is similar to `task.spawn`, but doesn't return a thread, and instead reuses a thread if possible. This has been benchmarked many times to produce a significant performance increase.

```lua
Spawn(function()
	print("Hello, world!")
end)

-- You can also pass arguments
Spawn(print, "Hello,", "world!")

-- Especially useful for functions that need to be run in their own thread
Spawn(function()
	while true do
		print("Hello, world!")
		task.wait(1)
	end
end)
```
