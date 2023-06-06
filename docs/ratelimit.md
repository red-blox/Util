# Ratelimit

Ratelimits many keys in a very intuitive interface.

```lua
<T>(
	Limit: number,
	Interval: number
) -> (T?) -> boolean
```

This function takes a limit and interval for resetting said limit, and returns a function that takes a key and returns whether or not the key has been used **more than the limit**.

```lua
-- 3 calls every 10 seconds
local LimitCheck = Ratelimit(3, 10)

LimitCheck("Key1") -- true
LimitCheck("Key1") -- true
LimitCheck("Key1") -- true
LimitCheck("Key1") -- false
```

::: tip
The limit is exclusive, use the maximum amount of calls you want to allow as the limit.
:::

Ratelimits can also be used without keys.

```lua
-- 3 calls every 10 seconds
local LimitCheck = Ratelimit(3, 10)

LimitCheck() -- true
LimitCheck() -- true
LimitCheck() -- true
LimitCheck() -- false
```
