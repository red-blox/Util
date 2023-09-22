# Fetch

A Future based HTTP request utility very similar to Javascript's fetch.

```lua
(
	Resource: string,
	Options: {
		Method: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS" | "CONNECT" | "TRACE"?,
		Headers: { [string]: string }?,
		Body: string | { [string]: any }?,
	}?
) -> Future<{
	Body: string,
	Headers: { [string]: string },
	Status: number,
	StatusText: string,
	Ok: boolean,
	Url: string,
	Json: (self) -> (boolean, any),
}>
```

Fetch is passed a resource and an optional options table, it returns a future containing a boolean for success and a response.

```lua
local Success, Response = Fetch("https://example.com/"):Await()

if Success and Response.Ok then
	print(Response.Body)
end
```

The options table can be used to set the request method, headers, and body. By default it will use the `GET` method with no headers or body.

```lua
local Success, Response = Fetch("https://example.com/", {
	Method = "POST",
	Headers = {
		["Content-Type"] = "application/json",
	},
	Body = {
		Hello = "World",
	},
}):Await()
```

::: tip
The `Body` option can be a string or a table. If it is a table it will be encoded as JSON.
:::

The response contains the following fields:

- `Body` - The response body as a string.
- `Headers` - A table of headers.
- `Status` - The response status code.
- `StatusText` - The response status text.
- `Ok` - A boolean indicating if the response was successful.
- `Url` - The final URL of the response.

The response also contains a `Json` method which will decode the response body as JSON.

```lua
local Success, Response = Fetch("https://example.com/"):Await()

if Success and Response.Ok then
	local Success, Data = Response:Json()

	if Success then
		print(Data.Hello)
	end
end
```

The `Json` method will return a boolean for the success of decoding the body, and the decoded body.
