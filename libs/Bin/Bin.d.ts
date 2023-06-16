export type BinItem = Instance | RBXScriptConnection | (() => unknown);

/**
 * Adds item to Bin.
 * ```ts
 * const Part: Part = Add<Part>(new Instance("Part"));
 *
 * Add<RBXScriptConnection>(Part.Touched.Connect(() => {
 *     print("Touched!");
 * }));
 *
 * Add<Callback>(() => {
 *     print("Emptying bin!");
 * });
 * ```
 * @param Item
 */
declare function Add<T>(Item: T & BinItem): T & BinItem;

/**
 * Empties the Bin - destroys added instances, disconnects added connections, calls added functions.
 */
declare function Empty(): void;

/**
 * Manages cleanup for objects that cannot be garbage collected.
 * This function creates a Bin, and returns two functions. The first can be used to add items to the bin, and the second can be used to "empty" the bin,
 * destroying all the items in it.
 * ```ts
 * const [Add, Empty] = Bin();
 *
 * const Part: Part = Add<Part>(new Instance("Part"));
 *
 * Add<RBXScriptConnection>(Part.Touched.Connect(() => {
 *     print("Touched!");
 * }));
 *
 * Add<Callback>(() => {
 *     print("Emptying bin!");
 * });
 *
 * Empty()
 * ```
 */
export function Bin(): LuaTuple<[typeof Add, typeof Empty]>;
