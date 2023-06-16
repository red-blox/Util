import { promise } from "../../red-blox_promise@1.0.0/promise/Promise";

export type Response = {
	Body: string;
	Headers: { [key: string]: string };
	Status: number;
	StatusText: string;
	Ok: boolean;
	Url: string;

	Json(): unknown;
};

export type Options = {
	Method?: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS" | "CONNECT" | "TRACE";
	Headers?: { [key: string]: string };
	Body?: string | { [key: string]: unknown };
};

export default function Fetch(Resource: string, Options?: Options): promise<Response, unknown>;
