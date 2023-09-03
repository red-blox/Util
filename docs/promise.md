# Promise

A promise implementation that prioritizes speed and ease of use.

A Promise is an object that represents an asynchronous operation. A Promise can be in one of three states: `Pending`, `Resolved`, or `Rejected`. The pending state is when the operation is still in progress, the resolved state is when the operation has completed successfully, and the rejected state is when the operation has failed.

Promises are by far the most complex utility here. More a better overview of Promises in general, I suggest reading [this article](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises) on MDN.

::: warning
It is now suggested that you use [Futures](./future) over Promises. Futures provide significant performance improvements and intellisense with luau.
:::

## Constructing Promises

There are multiple ways to construct a Promise.

### `Promise.new`

`Promise.new` is the base constructor for a Promise. You pass a function that takes two functions, `Resolve` and `Reject`. This function can do any operation, if the operation fails or the function errors, the `Reject` function will be called with the error. If the operation succeeds, the `Resolve` function should be called, passing in the values you want to resolve the Promise with.

```lua
local PlayerDataPromise = Promise.new(function(Resolve, Reject)
	-- If this errors, the promise will be rejected with the error
	-- If this succeeds, the promise will be resolved with the data
	Resolve(DataStoreService:GetDataStore("PlayerData"):GetAsync(Player.UserId))
end)
```

### `Promise.Resolve` and `Promise.Reject`

If you already have a value that you would like to wrap a Promise around, use these. These will synchronously return a Promise with the value and state requested.

```lua
local ResolvedPromise = Promise.Resolve("This promise resolved!")
local RejectedPromise = Promise.Reject("This promise rejected!")
```

## `Promise.Retry` and `Promise.RetryWithDelay`

These functions are wrappers around `Promise.new` that will retry an operation until it succeeds or the max number of retries is reached. `Promise.Retry` will retry the operation immediately, while `Promise.RetryWithDelay` will retry the operation after a delay. If the max number of retries is reached the Promise will be rejected with the last error.

```lua
-- Retry to a max of 10 times
local PlayerDataPromise = Promise.Retry(10, function(Player)
	return PlayerDataStore:GetAsync(Player.UserId)
end)

-- Retry to a max of 10 times with a 5 second delay in between each attempt
local PlayerDataPromise = Promise.RetryWithDelay(10, 5, function(Player)
	return PlayerDataStore:GetAsync(Player.UserId)
end)
```

## Chaining Promises

The real power of Promises comes from the ability to chain them together. Using the `Then`, `Catch`, or `Finally` methods you can chain Promises together as each of those return a Promise themselves.

### `Promise:Then`

`Promise:Then` takes two functions, `OnResolve` and `OnReject`. If the Promise is resolved, `OnResolve` will be called with the value the Promise was resolved with. If the Promise is rejected, `OnReject` will be called with the error the Promise was rejected with. `Promise:Then` returns a new Promise that will be resolved with the value returned from the respective handler.

```lua
Promise.new(function(Resolve, Reject)
	task.wait(5)

	Resolve("Hello, world")
end):Then(function(Value)
	print(Value) -- "Hello, world"

	return Value .. "!"
end):Then(function(Value)
	print(Value) -- "Hello, world!"
end)
```

When the `Then` method lacks the callback to relevant state, the Promise will simply adopt the state of the parent promise. This allows you to safely omit the `OnReject` callback until the final `:Catch` call.

```lua
Promise.new(function(Resolve, Reject)
	task.wait(5)

	Reject("Hello, world")
end):Then(function(Value)
	-- this function will never be called
end):Catch(function(Error)
	print(Error) -- "Hello, world"
end)
```

### `Promise:Catch` and `Promise:Finally`

These two functions are wrappers around `Promise:Then`.

`Promise:Catch` is a wrapper around `Promise:Then` that only takes the `OnReject` callback. This is useful for when you want to handle the error, but don't want to change the value of the Promise.

`Promise:Finally` is a wrapper around `Promise:Then` that takes both the `OnResolve` and `OnReject` callbacks. This is useful for when you want to do something regardless of the state of the Promise. Note that the value of the Promise is not passed to the callback, only the state of the Promise.

```lua
Promise.new(function(Resolve, Reject)
	task.wait(5)

	Reject("Hello, world")
end):Catch(function(Error)
	print(Error) -- "Hello, world"

	return "Goodbye, world"
end):Finally(function(State)
	print(State) -- "Resolved"
end)
```

## Awaiting Promises

### `Promise:Await`

`Promise:Await` is a method that will synchronously wait for the Promise to resolve or reject. If the Promise is resolved, the value will be returned. If the Promise is rejected, the error will be thrown.

```lua
-- This value will be "Hello, world"
local Value = Promise.new(function(Resolve, Reject)
	task.wait(5)

	Resolve("Hello, world")
end):Await()

-- This will error with "Hello, world"
local Value = Promise.new(function(Resolve, Reject)
	task.wait(5)

	Reject("Hello, world")
end):Await()
```

### `Promise:StatusAwait`

This method is identical to `Await`, except that instead of throwing an error, it's first return is the status of the Promise, and the rest of the returns are the values or error(s).

```lua
-- This value will be "Resolved", "Hello, world"
local Status, Value = Promise.new(function(Resolve, Reject)
	task.wait(5)

	Resolve("Hello, world")
end):StatusAwait()

-- This value will be "Rejected", "Hello, world"
local Status, Value = Promise.new(function(Resolve, Reject)
	task.wait(5)

	Reject("Hello, world")
end):StatusAwait()
```

## Multiple Promises

Promise has many constructors that allow you to work with many Promises at once.

### `Promise.All`

This function takes a list of Promises, and returns a Promise that will resolve when all of the Promises passed to it resolve and will reject when any of the Promises reject.

```lua
Promise.All(PromiseList):Then(function(Values)
	-- Values is a list of the first value resolved from each Promise
	-- The index of the value corresponds to the index of the Promise in the list

	for Index, Value in Values do
		print(Index, Value)
	end
end, function(Error)
	-- Error is the error of the first Promise to reject
	print(`Error: {Error}`)
end)
```

::: tip
If the Promise list is empty, the Promise will resolve immediately and synchronously with an empty list.
:::

### `Promise.AllSettled`

This function takes a list of Promises, and returns a Promise that will resolve when all of the Promises passed to it resolve or reject.

```lua
Promise.AllSettled(PromiseList):Then(function(Values)
	-- Values is a list of the statuses of each Promise
	-- The index of the value corresponds to the index of the Promise in the list

	for Index, Value in Values do
		print(Index, Value)
	end
end)
```

::: tip
If the Promise list is empty, the Promise will resolve immediately and synchronously with an empty list.
:::

### `Promise.Any`

This function takes a list of Promises, and returns a Promise that will resolve when any of the Promises passed to it resolve and will reject when all of the Promises reject.

```lua
Promise.Any(PromiseList):Then(function(Value)
	-- Value is the first value resolved from any of the Promises
	print(Value)
end, function(Errors)
	-- Errors is a list of the errors of each Promise
	-- The index of the error corresponds to the index of the Promise in the list

	for Index, Error in Errors do
		print(Index, Error)
	end
end)
```

::: tip
If the Promise list is empty, the Promise will reject immediately and synchronously with an empty list.
:::

### `Promise.Race`

This function takes a list of Promises, and returns a Promise that will adopt the state of the first resolved or rejected Promise in the list.

```lua
Promise.Race(PromiseList):Then(function(...)
	-- ... is the values of the first Promise to resolve
	-- Note that this is the only "multiple Promise" function that
	-- resolves with multiple values

	print(...)
end, function(...)
	print(...)
end)
```

::: tip
If the Promise list is empty, the Promise will reject immediately and synchronously with `No promises to resolve.`
:::
