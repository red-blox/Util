# Collection

Handles instance addition and removal from collections.

```lua
(
	Tag: string,
	Start: (Instance) -> (() -> ()?)
) -> () -> ()
```

This function will call the given callback for each instance with the given tag, both instances that already have the tag, and instances that will be added in the future. It returns a function that can be called to stop the collection.

```lua
local Stop = Collection("Tag", function(Instance)
	print("Tag Added")

	-- the cleanup function is optional
	return function()
		print("Tag Removed")
	end
end)

-- After 10 seconds calls all cleanup functions and stops the collection
task.wait(10)
Stop()
```

::: danger
Yielding in the `Start` function can cause the instance to never be cleaned up. Do not yield in the `Start` function.
:::
