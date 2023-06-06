# Bin

Manages cleanup for objects that cannot be garbage collected.

```lua
() -> (
	<T>(T & (Instance | RBXScriptConnection | () -> ...any)) -> (T),
	() -> ()
)
```

This function creates a `Bin`, and returns two functions. The first can be used to add items to the bin, and the second can be used to "empty" the bin, destroying all the items in it.

```lua
local Add, Empty = Bin()

-- Add returns the item you added
local Part = Add(Instance.new("Part"))

Add(Part.Touched:Connect(function()
	print("Touched!")
end))

Add(function()
	print("Emptying bin!")
end)

Empty()
```

Instances will be destroyed, connections will be disconnected, and functions will be called when the bin is emptied. Bins can be reused after empty.

::: danger
Do not pass tables to a Bin, it will not call any operation on them.
:::
