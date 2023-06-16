export type BinItem = Instance | RBXScriptConnection | (() => unknown);

declare function Add<T>(Item: T & BinItem): T & BinItem;
declare function Empty(): void;

export default function Bin(): LuaTuple<[typeof Add, typeof Empty]>;
