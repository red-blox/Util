export type BinItem = Instance | RBXScriptConnection | (() => unknown);

/**
 * Adds item to Bin.
 * ```ts
 * Add<RBXScriptConnection>(Heartbeat);
 * ```
 * @param Item
 */
declare function Add<T>(Item: T & BinItem): T & BinItem;

/**
 * Empties Bin - destroys instances, disconnects connections, calls functions.
 */
declare function Empty(): void;

/**
 * Creates a new Bin object.
 * ```ts
 * const [Add, Empty] = Bin();
 * ```
 */
export function Bin(): LuaTuple<[typeof Add, typeof Empty]>;
