# Signal

A signal implementation without connection objects.

```lua
<T...>() -> Signal<T...>
```

This function returns a new Signal object. A Signal object is used to fire any number of events and listen to them in any number of callbacks.

```lua
local LogSignal = Signal()

LogSignal:Connect(function(Value)
	print(Value)
end)

LogSignal:Fire("Hello, world!")
```

## `Signal:Connect`

To listen to values fired from a Signal, use the `Connect` method. This will connect the listener to the Signal and return a function that can be used to disconnect the listener from the signal. Listeners are passed all values fired.

```lua
local Disconnect = Signal:Connect(function(Value)
	print(Value)
end)

Signal:Fire("Hello, world!") -- "Hello, world!"
Disconnect()
Signal:Fire("Hello, world!") -- No output
```

::: tip
Why does `Connect` return a function? This is to allow for easy use with other utilities like Bin, and to reduce bloat. An entire table and object is not needed to wrap a single function.
:::

## `Signal:Once`

Similar to Connect, with the difference being that the listener provided will only run once when the signal is fired. The connection is also returned which allows you to disconnect it at anytime.

```lua
Signal:Once(function(Value)
	print(Value)
end)

Signal:Fire("Hello, world!") -- "Hello, world!"
Signal:Fire("Hello, world!") -- No output
```

## `Signal:Fire`

To fire a value from a Signal, use the `Fire` method. This will fire the passed values to all connected listeners.

```lua
Signal:Fire("Hello, world!")

-- You can also fire multiple values
Signal:Fire("Hello", "world", 15, true)
```

## `Signal:Wait`

This method yields until the next time the Signal is fired, and returns all values fired.

```lua
local a, b, c = Signal:Wait()
```

## `Signal:DisconnectAll`

This method disconnects all listeners from the Signal, enabling it to be garbage collected.

```lua
Signal:DisconnectAll()
```
