import { promise } from "@redblox/promise";

type Response = {
	Body: string;
	Headers: { [key: string]: string };
	Status: number;
	StatusText: string;
	Ok: boolean;
	Url: string;

	Json(): promise<unknown, unknown>;
};

type Options = {
	Method?: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS" | "CONNECT" | "TRACE";
	Headers?: { [key: string]: string };
	Body?: string | { [key: string]: unknown };
};

/**
 * A Promise based HTTP request utility very similar to fetch.
 * This utility takes a resource and an `Options` table and returns a Promise that resolves to a response object. The request options contain the method, any headers, and the body of the request. If you pass a table as the body, it will be encoded as JSON. The response object contains the body, headers, status code, status text, and the URL of the request. The response object also contains a `Json` method that returns a Promise that resolves to the JSON encoded body.
 * ```ts
 * Fetch("https://api.quotable.io/random").Then((Response) => {
 *     return $tuple(Response.Json());
 * }).Then((Json: { [key: string]: unknown }) => {
 *     print(`${Json.author} once said '${Json.content}'`);
 * });
 * ```
 * @param Resource URL to fetch
 * @param Options Request options
 */
declare function Fetch(Resource: string, Options?: Options): promise<Response, unknown>;

declare namespace Fetch {
	export { Response, Options };
}

export = Fetch;
