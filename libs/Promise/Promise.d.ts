type UnknownTuple = Array<unknown> & { readonly LUA_TUPLE: never };
export type State = "Resolved" | "Rejected";

declare class promise<V, E> {
	/**
	 * `new Promise` is the base constructor for a Promise. You pass a function that takes two functions, `Resolve` and `Reject`. This function can perform any operation. If the operation fails or errors, `Reject` will be called with an error. If the operation succeeds, `Resolve` should be called, passing in the values you want to resolve the Promise with.
	 * ```ts
	 * const PlayerDataPromise = new Promise((Resolve: Callback, Reject: Callback) => 
	 *     Resolve(DataStoreService.GetDataStore("PlayerData").GetAsync(Player.UserId)));
	 * ```
	 * @param Callback
	 */
	public constructor(
		// eslint-disable-next-line prettier/prettier
			Callback: (
				Resolve: (...Args: V[]) => void,
				Reject: (...Args: E[]) => void
			) => void,
	);

	/**
	 * Wraps the passed argument(s) with a resolved Promise.
	 * ```ts
	 * const ResolvedPromise = Promise.Resolve("This Promise resolved!");
	 * ```
	 * @param Args
	 */
	public Resolve<RV>(...Args: V[]): promise<RV, E>;

	/**
	 * Wraps the passed argument(s) with a rejected Promise.
	 * ```ts
	 * const RejectedPromise = Promise.Reject("This Promise rejected!");
	 * ```
	 * @param Args
	 */
	public Reject<RE>(...Args: E[]): promise<V, RE>;

	/**
	 * Takes a list of Promises, and returns a Promise that will:
	 * - Resolve when all of the Promises resolve
	 * - Reject if any of the Promises reject
	 * ```ts
	 * Promise.All(PromiseList).Then((Values: unknown[]) => {
	 *	   // Values is a list of the first value resolved from each Promise
	 *     // The index of the value corresponds to the index of the Promise in the list
	 *
	 *     for (key in Values) {
	 *         print(`${key}: ${Values[key]}`);
	 * 	   }
	 * }, (Error: unknown) => {
	 *     // Error is the error of the first Promise to reject
	 *     print(`Error: ${Error}`);
	 * });
	 * ```
	 * @param PromiseList
	 */
	public All<LV, LE, RV>(PromiseList: promise<LV, LE>[]): promise<RV, LE>;

	/**
	 * Takes a list of Promises, and returns a Promise that will resolve when all passed Promises resolve or reject.
	 * ```ts
	 * Promise.AllSettled(PromiseList).Then((Values) => {
	 *	   // Values is a list of the first value resolved from each Promise
	 *     // The index of the value corresponds to the index of the Promise in the list
	 
	 *     for (key in Values) {
	 *         print(`${key}: ${Values[key]}`);
	 * 	   }
	 * });
	 * ```
	 * @param PromiseList
	 */
	public AllSettled<LV, LE, RV>(PromiseList: promise<LV, LE>[]): promise<RV, LE>;

	/**
	 * Takes a list of Promises, and returns a Promise that will:
	 * - Resolve when any of the passed Promises resolve
	 * - Reject when all of the passed Promises reject
	 * ```ts
	 * Promise.Any(PromiseList).Then((Value: unknown) => {
	 *     // Value is the first value resolved from any of the Promises
	 *     print(Value);
	 * }, (Errors) => {
	 *     // Errors is a list of the errors from each Promise
	 *     // The index of the error corresponds to the index of the Promise in the list
	 *
	 * 	   for (key in Errors) {
	 *         print(`${key}: ${Values[key]}`);
	 *     }
	 * });
	 * ```
	 * @param PromiseList
	 */
	public Any<LV, LE, RV>(PromiseList: promise<LV, LE>[]): promise<RV, LE>;

	/**
	 * Takes a list of promises, and returns a Promise that will adopt the state of the first resolved or rejected Promise in the list.
	 * ```ts
	 * Promise.Race(PromiseList).Then((...Values: unknown[]) => {
	 *     // Values is the values of the first Promise to resolve
	 *     // Note that this is the only "multiple Promise" function that
	 *     // resolves with multiple values.
	 *
	 *     print(...Values);
	 * }, (...Errors: unknown[]) => {
	 *     print(...Errors);
	 * })
	 * @param PromiseList
	 */
	public Race<LV, LE, RV>(PromiseList: promise<LV, LE>[]): promise<RV, LE>;

	/**
	 * Takes two functions, `OnResolve` and `OnReject`. If the Promise is resolved, `OnResolve` will be called with the value the Promise was resolved with. If the Promise is rejected, `OnReject` will be called with the error the Promise was rejected with.
	 * `Promise.Then` returns a new Promise that will be resolved with the value returned from the respective handler.
	 * ```ts
	 * new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Resolve("Hello, World");
	 * }).Then((...Values: string[]) => {
	 *     print(...Values); // "Hello, World"
	 *
	 *     return `${Values[1]"!"}`;
	 * }).Then((...Values: string[]) => {
	 *     print(...Values); // "Hello, World!"
	 * });
	 * ```
	 *
	 * When the `Then` method lacks the callback to relevant state, the Promise will simply adopt the state of the parent Promise. This allows you to safely omit the `OnReject` callback until the final `Catch` call.
	 * ```ts
	 * new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Resolve("Hello, World");
	 * }).Then((...Values: string[]) => {
	 *     // This function will never be called
	 * }).Catch((Error: string) => {
	 *     print(Error);
	 * })
	 * ```
	 * @param OnResolve
	 * @param OnReject
	 */
	public Then<LV, LE, RV>(
		OnResolve?: (...Args: LV[]) => LuaTuple<RV[]> | void,
		OnReject?: (...Args: LE[]) => LuaTuple<LE[]> | void,
	): promise<RV, LE>;

	/**
	 * `Promise.Catch` is a wrapper around `Promise.Then` that only takes the `OnReject` callback. This is useful for when you want to handle the error, but don't want to change the value of the Promise.
	 * ```ts
	 * new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Reject("Hello, World");
	 * }).Catch((Error: string) => {
	 *     print(Error); // "Hello, World"
	 *
	 *     return "Goodbye, World";
	 * });
	 * ```
	 * @param OnReject
	 */
	public Catch<RE>(OnReject: (...Args: E[]) => void): promise<V, RE>;

	/**
	 * `Promise.Finally` is a wrapper around `Promise.Then` that takes both the `OnResolve` and `OnReject` callbacks. This is useful for when you want to do something regardless of the state of the Promise. Note that the value of the Promise is not passed to the callback, only the state of the Promise.
	 * ```ts
	 * new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Reject("Hello, World");
	 * }).Catch((Error: string) => {
	 *     print(Error); // "Hello, World"
	 *
	 *     return "Goodbye, World";
	 * }).Finally((State: State) => {
	 *     print(State); // "Resolved"
	 * });
	 * ```
	 * @param Finally
	 */
	public Finally<RV>(Finally: (State: State) => void): promise<RV, E>;

	/**
	 * `Promise.Await` is a method that will synchronously wait for the Promise to resolve or reject. If the Promise is resolved, the value will be returned. If the Promise is rejected, the error will be thrown.
	 * ```ts
	 * // The value will be "Hello, World"
	 * const Value = new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Resolve("Hello, World");
	 * }).Await();
	 *
	 * // This will error with "Hello, World"
	 * const Value = new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Reject("Hello, World");
	 * }).Await();
	 * ```
	 */
	public Await(): V;

	/**
	 * This method is identical to `Await`, except that instead of throwing an error, it's first return is the status of the Promise, and the rest of the returns are the value(s) or error(s).
	 * ```ts
	 * // This value will be "Resolved", "Hello, World"
	 * const [Status: State, Value: string] = new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Resolve("Hello, World");
	 * }).StatusAwait();
	 *
	 * // This value will be "Rejected", "Hello, World"
	 * const [Status: State, Value: string] = new Promise<string, string>((Resolve: Callback, Reject: Callback) => {
	 *     task.wait(5);
	 *
	 *     Reject("Hello, World");
	 * }).StatusAwait();
	 * ```
	 */
	public StatusAwait(): LuaTuple<[State, UnknownTuple]>;
}

export { promise };
