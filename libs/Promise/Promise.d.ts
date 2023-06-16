type UnknownTuple = Array<unknown> & { readonly LUA_TUPLE: never };

declare class promise<V, E> {
	public constructor(
		// eslint-disable-next-line prettier/prettier
		Callback: (
            Resolve: (...Args: V[]) => void,
            Reject: (...Args: E[]) => void
        ) => void,
	);

	public Resolve(...Args: V[]): promise<V, E>;
	public Reject(...Args: V[]): promise<V, E>;
	public All<LV, LE>(PromiseList: promise<LV, LE>[]): promise<LV, LE>;
	public AllSettled<LV, LE>(PromiseList: promise<LV, LE>[]): promise<LV, LE>;
	public Any<LV, LE>(PromiseList: promise<LV, LE>[]): promise<LV, LE>;
	public Race<LV, LE>(PromiseList: promise<LV, LE>[]): promise<LV, LE>;
	public Then<LV, LE>(
		OnResolve?: (...Args: LV[]) => LuaTuple<LV[]> | void,
		OnReject?: (...Args: LE[]) => LuaTuple<LE[]> | void,
	): promise<LV, LE>;
	public Catch(OnReject: (...Args: E[]) => void): promise<V, E>;
	public Finally(Finally: (Status: "Resolved" | "Rejected") => void): promise<V, E>;
	public Await(): V;
	public StatusAwait(): LuaTuple<["Resolved" | "Rejected", UnknownTuple]>;
}

export = promise;
