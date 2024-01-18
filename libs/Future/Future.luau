local Spawn = require(script.Parent.Spawn)

export type Future<T...> = {
	ValueList: { any }?,
	AfterList: { (T...) -> () },
	YieldList: { thread },

	IsComplete: (self: Future<T...>) -> boolean,
	IsPending: (self: Future<T...>) -> boolean,

	Expect: (self: Future<T...>, Message: string) -> T...,
	Unwrap: (self: Future<T...>) -> T...,
	UnwrapOr: (self: Future<T...>, T...) -> T...,
	UnwrapOrElse: (self: Future<T...>, Else: () -> T...) -> T...,

	After: (self: Future<T...>, Callback: (T...) -> ()) -> (),
	Await: (self: Future<T...>) -> T...,
}

local function IsComplete<T...>(self: Future<T...>): boolean
	return self.ValueList ~= nil
end

local function IsPending<T...>(self: Future<T...>): boolean
	return self.ValueList == nil
end

local function Expect<T...>(self: Future<T...>, Message: string): T...
	assert(self.ValueList, Message)

	return table.unpack(self.ValueList)
end

local function Unwrap<T...>(self: Future<T...>): T...
	return self:Expect("Attempt to unwrap pending future!")
end

local function UnwrapOr<T...>(self: Future<T...>, ...): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		return ...
	end
end

local function UnwrapOrElse<T...>(self: Future<T...>, Else: () -> T...): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		return Else()
	end
end

local function After<T...>(self: Future<T...>, Callback: (T...) -> ()): T...
	if self.ValueList then
		Spawn(Callback, table.unpack(self.ValueList))
	else
		table.insert(self.AfterList, Callback)
	end
end

local function Await<T...>(self: Future<T...>): T...
	if self.ValueList then
		return table.unpack(self.ValueList)
	else
		table.insert(self.YieldList, coroutine.running())

		return coroutine.yield()
	end
end

local function Future<T..., A...>(Callback: (A...) -> T..., ...: A...): Future<T...>
	local self: Future<T...> = {
		ValueList = nil,
		AfterList = {},
		YieldList = {},

		IsComplete = IsComplete,
		IsPending = IsPending,

		Expect = Expect,
		Unwrap = Unwrap,
		UnwrapOr = UnwrapOr,
		UnwrapOrElse = UnwrapOrElse,

		After = After,
		Await = Await,
	} :: any

	Spawn(function(self: Future<T...>, Callback: (A...) -> T..., ...: A...)
		local ValueList = { Callback(...) }
		self.ValueList = ValueList

		for _, Thread in self.YieldList do
			task.spawn(Thread, table.unpack(ValueList))
		end

		for _, Callback in self.AfterList do
			Spawn(Callback, table.unpack(ValueList))
		end
	end, self, Callback, ...)

	return self
end

local function Try<T..., A...>(Callback: (A...) -> T..., ...: A...): Future<(boolean, T...)>
	return Future(pcall, Callback, ...)
end

-- Use try as we don't know if the future could error or not, and erroring futures create memory leaks.
local function ToFuture<T..., A...>(Callback: (A...) -> T...): (A...) -> Future<(boolean, T...)>
	return function(...)
		return Try(Callback, ...)
	end
end

-- Only works for futures returning one value (which to be honest is most cases, hence why it gets its own function)
-- Has a relatively unintuitive type error when using a future with more than one return value, so it doesn't get to be called just "All"
local function AllSingle<T>(futures: { Future<T> }): Future<{ T }>
	return Future(function(futures: { Future<T> }): { T }
		local futureValues: any = table.create(#futures)
		for k, future in futures do
			futureValues[k] = future:Await()
		end
		return futureValues
	end, futures)
end

-- Works for futures returning multiple values, but without table tuple types, we can only return a function that returns a tuple to preserve typing.
local function All<T...>(futures: { Future<T...> }): Future<{ () -> T... }>
	return Future(function(futures: { Future<T...> }): { () -> T... }
		local futureValues: any = table.create(#futures)
		for k, future in futures do
			local values = table.pack(future:Await())
			futureValues[k] = function()
				return table.unpack(values)
			end
		end
		return futureValues
	end, futures)
end

local function Any<T...>(futures: { Future<T...> }): Future<T...>
	return Future(function(futures: { Future<T...> })
		local thread = coroutine.running()
		local returned = false

		for _, future in futures do
			if future:IsComplete() then
				returned = true
				return future:Unwrap()
			end

			future:After(function(...)
				if not returned then
					returned = true
					task.spawn(thread, ...)
				end
			end)
		end

		return coroutine.yield()
	end, futures)
end

local function Value<T...>(...: T...): Future<T...>
	return Future(function(...)
		return ...
	end, ...)
end

return {
	new = Future,
	Try = Try,
	ToFuture = ToFuture,
	All = All,
	AllSingle = AllSingle,
	Any = Any,
	Value = Value,
}
