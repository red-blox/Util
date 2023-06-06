local HttpService = game:GetService("HttpService")

local Promise = require(script.Parent.Promise)

export type Response = {
	Body: string,
	Headers: { [string]: string },
	Status: number,
	StatusText: string,
	Ok: boolean,
	Url: string,

	Json: (self: Response) -> any,
}

export type Options = {
	Method: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS" | "CONNECT" | "TRACE"?,
	Headers: { [string]: string }?,
	Body: string | { [string]: any }?,
}

local function Json(self: Response): any
	return Promise.new(function(Resolve, Reject)
		Resolve(HttpService:JSONDecode(self.Body :: string))
	end)
end

return function(Resource: string, Options: Options?)
	local RealOptions: Options = Options or {}
	local RealBody = if type(RealOptions.Body) == "table"
		then HttpService:JSONEncode(RealOptions.Body)
		else RealOptions.Body

	return Promise.new(function(Resolve)
		local HttpResponse = HttpService:RequestAsync({
			Url = Resource,
			Method = RealOptions.Method or "GET",
			Headers = RealOptions.Headers or {},
			Body = RealBody,
		})

		Resolve({
			Body = HttpResponse.Body :: string,
			Headers = HttpResponse.Headers,
			Status = HttpResponse.StatusCode,
			StatusText = HttpResponse.StatusMessage,
			Ok = HttpResponse.Success,
			Url = Resource,

			Json = Json,
		})
	end)
end
