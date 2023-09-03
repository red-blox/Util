# Guard

A runtime type checker with support for luau types.

Guard is very similar to and takes inspiration from [Osyris' `t` module](https://github.com/osyrisrblx/t). The primary difference between the two is that Guard is designed to be used with luau, and as such supports luau types.

## Design

Every Guard function either returns a check, or is a check.

### What is a Check?

A check is a function that takes a value of unknown type and returns a value of known type or errors. You can combine checks to create more complex checks.

### Example Usage

```lua
local NumberListCheck = Guard.List(Guard.Number)

local NumberList = NumberListCheck({1, 2, 3}) -- Passes and returns {1, 2, 3}
local StringList = NumberListCheck({"a", "b", "c"}) -- Fails and errors
```

If you wish to check a value without erroring, you can use `Check`:

```lua
local NumberListCheck = Guard.Check(Guard.List(Guard.Number))

local Pass, NumberList = NumberListCheck({1, 2, 3}) -- Passes and returns true, {1, 2, 3}
local Pass, StringList = NumberListCheck({"a", "b", "c"}) -- Fails and returns false, nil
```

## Luau Primitive Types

### `Guard.Any`

A check that passes any value.

```lua
local Value = Guard.Any(1) -- Passes and returns 1
local Value = Guard.Any("Hello") -- Passes and returns "Hello"
local Value = Guard.Any({}) -- Passes and returns {}
```

### `Guard.Boolean`

A check that passes boolean values.

```lua
local Value = Guard.Boolean(true) -- Passes and returns true
local Value = Guard.Boolean(false) -- Passes and returns false

local Value = Guard.Boolean(1) -- Fails and errors
local Value = Guard.Boolean("Hello") -- Fails and errors
local Value = Guard.Boolean({}) -- Fails and errors
```

### `Guard.Thread`

A check that passes thread values.

```lua
local Value = Guard.Thread(coroutine.create(function() end)) -- Passes and returns the thread
local Value = Guard.Thread(coroutine.running()) -- Passes and returns the thread
local Value = Guard.Thread(task.spawn(function() end)) -- Passes and returns the thread

local Value = Guard.Thread(1) -- Fails and errors
local Value = Guard.Thread("Hello") -- Fails and errors
local Value = Guard.Thread({}) -- Fails and errors
```

### `Guard.Nil`

A check that passes nil values.

```lua
local Value = Guard.Nil(nil) -- Passes and returns nil

local Value = Guard.Nil(1) -- Fails and errors
local Value = Guard.Nil("Hello") -- Fails and errors
local Value = Guard.Nil({}) -- Fails and errors
```

### `Guard.Number`

A check that passes number values.

```lua
local Value = Guard.Number(1) -- Passes and returns 1
local Value = Guard.Number(1.5) -- Passes and returns 1.5

local Value = Guard.Number("Hello") -- Fails and errors
local Value = Guard.Number({}) -- Fails and errors
```

### `Guard.String`

A check that passes string values.

```lua
local Value = Guard.String("Hello") -- Passes and returns "Hello"

local Value = Guard.String(1) -- Fails and errors
local Value = Guard.String({}) -- Fails and errors
```

## Combination Types

### `Guard.Or`

Returns a check that passes values that pass at least one of the two given checks.

```lua
local NumberOrStringCheck = Guard.Or(Guard.Number, Guard.String)

local Value = NumberOrStringCheck(1) -- Passes and returns 1
local Value = NumberOrStringCheck("Hello") -- Passes and returns "Hello"

local Value = NumberOrStringCheck({}) -- Fails and errors
```

You can only pass two checks to `Or`, if you want to pass more than two checks then you can chain `Or` calls:

```lua
local NumberOrStringOrBooleanCheck = Guard.Or(
	Guard.Number,
	Guard.Or(Guard.String, Guard.Boolean)
)

local Value = NumberOrStringOrBooleanCheck(1) -- Passes and returns 1
local Value = NumberOrStringOrBooleanCheck("Hello") -- Passes and returns "Hello"
local Value = NumberOrStringOrBooleanCheck(true) -- Passes and returns true

local Value = NumberOrStringOrBooleanCheck({}) -- Fails and errors
```

### `Guard.And`

Returns a check that passes values that pass both of the two given checks.

```lua
-- You can create and use custom check functions!
local NumberAndStringCheck = Guard.And(Guard.Number, function(Value: number)
	assert(Value > 0)

	return true
end)

local Value = NumberAndStringCheck(1) -- Passes and returns 1
local Value = NumberAndStringCheck(2) -- Passes and returns 2

local Value = NumberAndStringCheck(-1) -- Fails and errors
local Value = NumberAndStringCheck("Hello") -- Fails and errors
```

### `Guard.Optional`

Returns a check that passes values of the given check or nil.

```lua
local OptionalNumberCheck = Guard.Optional(Guard.Number)

local Value = OptionalNumberCheck(1) -- Passes and returns 1
local Value = OptionalNumberCheck(nil) -- Passes and returns nil

local Value = OptionalNumberCheck("Hello") -- Fails and errors
local Value = OptionalNumberCheck({}) -- Fails and errors
```

### `Guard.Literal`

Returns a check that passes values that are equal to the given literal.

```lua
local LiteralHelloCheck = Guard.Literal("Hello")

local Value = LiteralHelloCheck("Hello") -- Passes and returns "Hello"

local Value = LiteralHelloCheck("World") -- Fails and errors
local Value = LiteralHelloCheck(1) -- Fails and errors
local Value = LiteralHelloCheck({}) -- Fails and errors
```

## Complex Types

### `Guard.Map`

Returns a check that checks every key and value in a table.

```lua
local StringNumberMapCheck = Guard.Map(Guard.String, Guard.Number)

local Value = StringNumberMapCheck({Hello = 1, World = 2}) -- Passes and returns {Hello = 1, World = 2}
local Value = StringNumberMapCheck({}) -- Passes and returns {}

local Value = StringNumberMapCheck({Hello = 1, World = "2"}) -- Fails and errors
local Value = StringNumberMapCheck({Hello = 1, World = 2, 3}) -- Fails and errors
local Value = StringNumberMapCheck("Hello World") -- Fails and errors
```

### `Guard.Set`

Returns a check that validates every value is true and every key passes the given check.

```lua
local StringSetCheck = Guard.Set(Guard.String)

local Value = StringSetCheck({Hello = true, World = true}) -- Passes and returns {Hello = true, World = true}
local Value = StringSetCheck({}) -- Passes and returns {}

local Value = StringSetCheck({Hello = true, World = 2}) -- Fails and errors
local Value = StringSetCheck({Hello = true, World = true, 3}) -- Fails and errors
local Value = StringSetCheck("Hello World") -- Fails and errors
```

### `Guard.List`

Returns a check that validates every value passes the given check.

```lua
local NumberListCheck = Guard.List(Guard.Number)

local Value = NumberListCheck({1, 2, 3}) -- Passes and returns {1, 2, 3}
local Value = NumberListCheck({}) -- Passes and returns {}

local Value = NumberListCheck({1, 2, "3"}) -- Fails and errors
local Value = NumberListCheck("Hello World") -- Fails and errors
```

## Number Types

### `Guard.Integer`

A check that passes integer values.

```lua
local Value = Guard.Integer(1) -- Passes and returns 1
local Value = Guard.Integer(2) -- Passes and returns 2

local Value = Guard.Integer(1.5) -- Fails and errors
local Value = Guard.Integer("Hello") -- Fails and errors
local Value = Guard.Integer({}) -- Fails and errors
```

### `Guard.NumberMin`

Returns a check that passes number values greater than or equal to the given minimum.

```lua
local NumberMinCheck = Guard.NumberMin(5)

local Value = NumberMinCheck(6) -- Passes and returns 1
local Value = NumberMinCheck(7) -- Passes and returns 2

local Value = NumberMinCheck(5) -- Fails and errors
local Value = NumberMinCheck(4) -- Fails and errors
local Value = NumberMinCheck("Hello") -- Fails and errors
local Value = NumberMinCheck({}) -- Fails and errors
```

### `Guard.NumberMax`

Returns a check that passes number values less than or equal to the given maximum.

```lua
local NumberMaxCheck = Guard.NumberMax(5)

local Value = NumberMaxCheck(4) -- Passes and returns 1
local Value = NumberMaxCheck(3) -- Passes and returns 2

local Value = NumberMaxCheck(5) -- Fails and errors
local Value = NumberMaxCheck(6) -- Fails and errors
local Value = NumberMaxCheck("Hello") -- Fails and errors
local Value = NumberMaxCheck({}) -- Fails and errors
```

### `Guard.NumberMinMax`

Returns a check that passes number values between the given minimum and maximum.

```lua
local NumberMinMaxCheck = Guard.NumberMinMax(5, 10)

local Value = NumberMinMaxCheck(6) -- Passes and returns 1
local Value = NumberMinMaxCheck(7) -- Passes and returns 2

local Value = NumberMinMaxCheck(5) -- Fails and errors
local Value = NumberMinMaxCheck(4) -- Fails and errors
local Value = NumberMinMaxCheck(10) -- Fails and errors
local Value = NumberMinMaxCheck(11) -- Fails and errors
local Value = NumberMinMaxCheck("Hello") -- Fails and errors
local Value = NumberMinMaxCheck({}) -- Fails and errors
```

## Roblox Types

Guard only has built-in support for a select number of commonly used Roblox types. If you need to check a type that is not supported, you can create your own check function that does just that:

```lua
local function BrickColorCheck(Value: unknown)
	assert(typeof(Value) == "BrickColor")

	return Value
end
```

### `Guard.CFrame`

A check that passes CFrame values.

```lua
local Value = Guard.CFrame(CFrame.new()) -- Passes and returns the CFrame

local Value = Guard.CFrame(1) -- Fails and errors
local Value = Guard.CFrame("Hello") -- Fails and errors
local Value = Guard.CFrame({}) -- Fails and errors
```

### `Guard.Color3`

A check that passes Color3 values.

```lua
local Value = Guard.Color3(Color3.new()) -- Passes and returns the Color3

local Value = Guard.Color3(1) -- Fails and errors
local Value = Guard.Color3("Hello") -- Fails and errors
local Value = Guard.Color3({}) -- Fails and errors
```

### `Guard.DateTime`

A check that passes DateTime values.

```lua
local Value = Guard.DateTime(DateTime.now()) -- Passes and returns the DateTime

local Value = Guard.DateTime(1) -- Fails and errors
local Value = Guard.DateTime("Hello") -- Fails and errors
local Value = Guard.DateTime({}) -- Fails and errors
```

### `Guard.Instance`

A check that passes Instance values.

```lua
local Value = Guard.Instance(Instance.new("Part")) -- Passes and returns the Instance

local Value = Guard.Instance(1) -- Fails and errors
local Value = Guard.Instance("Hello") -- Fails and errors
local Value = Guard.Instance({}) -- Fails and errors
```

### `Guard.Vector2`

A check that passes Vector2 values.

```lua
local Value = Guard.Vector2(Vector2.new()) -- Passes and returns the Vector2

local Value = Guard.Vector2(1) -- Fails and errors
local Value = Guard.Vector2("Hello") -- Fails and errors
local Value = Guard.Vector2({}) -- Fails and errors
```

### `Guard.Vector2int16`

A check that passes Vector2int16 values.

```lua
local Value = Guard.Vector2int16(Vector2int16.new()) -- Passes and returns the Vector2int16

local Value = Guard.Vector2int16(1) -- Fails and errors
local Value = Guard.Vector2int16("Hello") -- Fails and errors
local Value = Guard.Vector2int16({}) -- Fails and errors
```

### `Guard.Vector3`

A check that passes Vector3 values.

```lua
local Value = Guard.Vector3(Vector3.new()) -- Passes and returns the Vector3

local Value = Guard.Vector3(1) -- Fails and errors
local Value = Guard.Vector3("Hello") -- Fails and errors
local Value = Guard.Vector3({}) -- Fails and errors
```

### `Guard.Vector3int16`

A check that passes Vector3int16 values.

```lua
local Value = Guard.Vector3int16(Vector3int16.new()) -- Passes and returns the Vector3int16

local Value = Guard.Vector3int16(1) -- Fails and errors
local Value = Guard.Vector3int16("Hello") -- Fails and errors
local Value = Guard.Vector3int16({}) -- Fails and errors
```

## `Guard.Check`

Returns a check that returns true if the given check passes, and false if it fails.

```lua
local NumberCheck = Guard.Check(Guard.Number)

local Pass, Value = NumberCheck(1) -- Passes and returns true, 1
local Pass, Value = NumberCheck("Hello") -- Fails and returns false, nil
```
