# Future

A lightweight class to represent asynchronous functions.

A Future is an object that represents an asynchronous operation. A Future is either pending or completed. When a Future is completed, it has a value.

## Constructing Futures

A Future can be constructed in one of two ways:

### `Future.new`

This is the base constructor for a Future. It takes a single argument, a function that takes any number of arguments, and returns any number of values. The function is called in a new thread, and the Future is completed with the return values of the function.

```lua
local future = Future.new(function()
	task.wait(1)

	return 1 + 1, "hello", true
end)
```

Using values from a scope outside of the function passed to `Future.new` is not recommended, as this will create a closure each time the function is called - preventing function caching. Instead you can pass values to the function using `Future.new`.

```lua
local future = Future.new(function(A, B, C)
	return A + B + C
end, 10, 20, 30)
```

::: danger
If the function passed to `Future.new` errors, the future will never be completed. If you need Future to catch errors, use a pcall or [`Future.Try`](#future-try).
:::

### `Future.Try`

This constructor wraps the given function and arguments in a pcall. The returned Future will be completed with the return values of the pcall, including the success boolean.

```lua
-- You can still pass arguments to Future.Try just like Future.new
local future = Future.Try(function(A, B, C)
	error("oops")
end, 10, 20, 30)
```

## Methods

### `Future:IsComplete`

Returns a boolean indicating whether the Future is complete.

```lua
if future:IsComplete() then
	local a, b, c = future:Unwrap()
end
```

### `Future:IsPending`

Returns a boolean indicating whether the Future is pending.

```lua
if future:IsPending() then
	local a, b, c = future:Await()
end
```

### `Future:Expect`

Returns the values of the Future if complete, otherwise it errors with the provided message.

```lua
local a, b, c = future:Expect("Future was not completed")
```

### `Future:Unwrap`

Returns the values of the Future if complete, otherwise it errors.

```lua
local a, b, c = future:Unwrap()
```

### `Future:UnwrapOr`

Returns the values of the Future if complete, otherwise it returns the provided default values.

```lua
local a, b, c = future:UnwrapOr(10, 20, 30)
```

### `Future:UnwrapOrElse`

Returns the values of the Future if complete, otherwise it calls the provided function and returns the values of the Future returned by the function.

```lua
local a, b, c = future:UnwrapOrElse(function()
	return 10, 20, 30
end)
```

### `Future:After`

Calls a function with the values a Future completes with after the future is completed.

```lua
future:After(function(a, b, c)
	print(a, b, c)
end)
```

### `Future:Await`

Returns the values of the Future if complete, otherwise it yields the current thread until the Future is completed.

```lua
local a, b, c = future:Await()
```

::: tip
It is important to note that unlike promises, `Future:Await` will never error.
:::
