# Fetch

A Promise based HTTP request utility very similar to fetch.

```lua
(
	Resource: string,
	Options: {
		Method: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS" | "CONNECT" | "TRACE"?,
		Headers: { [string]: string }?,
		Body: string | { [string]: any }?,
	}?
) -> Promise<{
	Body: string,
	Headers: { [string]: string },
	Status: number,
	StatusText: string,
	Ok: boolean,
	Url: string,
	Json: (self) -> Promise<any>,
}>
```

This utility takes a resource and an `Options` table and returns a Promise that resolves to a response object. The request options contain the method, any headers, and the body of the request. If you pass a table as the body, it will be encoded as JSON. The response object contains the body, headers, status code, status text, and the URL of the request. The response object also contains a `Json` method that returns a Promise that resolves to the JSON encoded body.

```lua
Fetch("https://api.quotable.io/random"):Then(function(Response)
	return Response:Json()
end):Then(function(Json)
	print(`{Json.author} once said '{Json.content}'`)
end)
```
