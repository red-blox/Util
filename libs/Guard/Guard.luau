local Guard = {}

export type Guard = (Value: any) -> boolean

function Guard.Type(Type: string)
	return function(Value: any)
		return typeof(Value) == Type
	end
end

function Guard.String(Pattern: string?, Min: number?, Max: number?)
	if Pattern == nil and Min == nil and Max == nil then
		return Guard.Type("string")
	end

	return function(Value: any)
		return type(Value) == "string"
			and (not Pattern or string.match(Value, Pattern))
			and (not Min or #Value >= Min)
			and (not Max or #Value <= Max)
	end
end

function Guard.Number(Min: number?, Max: number?)
	if Min == nil and Max == nil then
		return Guard.Type("number")
	end

	return function(Value: any)
		return type(Value) == "number" and (not Min or Value >= Min) and (not Max or Value <= Max)
	end
end

function Guard.Integer(Min: number?, Max: number?)
	if Min == nil and Max == nil then
		return Guard.Type("number")
	end

	return function(Value: any)
		return type(Value) == "number"
			and math.floor(Value) == Value
			and (not Min or Value >= Min)
			and (not Max or Value <= Max)
	end
end

function Guard.Literal(Literal: any)
	return function(Value: any)
		return Value == Literal
	end
end

function Guard.Union(...: Guard)
	local GuardList = { ... }

	return function(Value: any)
		for _, Guard in GuardList do
			if Guard(Value) then
				return true
			end
		end

		return false
	end
end

function Guard.Intersection(...: Guard)
	local GuardList = { ... }

	return function(Value: any)
		for _, Guard in GuardList do
			if not Guard(Value) then
				return false
			end
		end

		return true
	end
end

function Guard.Array(ValueGuard: Guard, Min: number?, Max: number?)
	return function(Value: any)
		if type(Value) ~= "table" then
			return false
		end

		local LastKey = 0
		for Key, Value in Value do
			if type(Key) ~= "number" or LastKey + 1 ~= Key then
				return false
			end

			if not ValueGuard(Value) then
				return false
			end

			LastKey = Key
		end

		local Length = #Value
		return (not Min or Length >= Min) and (not Max or Length <= Max)
	end
end

function Guard.Map(KeyGuard: Guard, ValueGuard: Guard)
	return function(Value: any)
		if type(Value) ~= "table" then
			return false
		end

		for Key, Value in Value do
			if not KeyGuard(Key) or not ValueGuard(Value) then
				return false
			end
		end

		return true
	end
end

function Guard.Set(ValueGuard: Guard)
	return function(Value: any)
		if type(Value) ~= "table" then
			return false
		end

		for Key, Value in Value do
			if Value ~= true or not ValueGuard(Value) then
				return false
			end
		end

		return true
	end
end

function Guard.Interface(Interface: { [string]: Guard })
	return function(Value: any)
		if type(Value) ~= "table" then
			return false
		end

		for Key in Value do
			if not Interface[Key] then
				return false
			end
		end

		for Key, Guard in Interface do
			if not Guard(Value[Key]) then
				return false
			end
		end

		return true
	end
end

function Guard.Optional(ValueGuard: Guard)
	return Guard.Union(ValueGuard, Guard.Literal(nil))
end

function Guard.Any()
	return true
end

Guard.Thread = Guard.Type("thread")
Guard.Boolean = Guard.Type("boolean")
Guard.Nil = Guard.Literal(nil)

return Guard
