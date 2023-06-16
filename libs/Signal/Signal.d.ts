/* eslint-disable @typescript-eslint/no-explicit-any */
import promise from "../../red-blox_promise@1.0.0/promise/Promise";

export type SignalNode<T> = {
	Next?: SignalNode<T>;
	Callback: (Value: T) => void;
};

export type Signal<T> = {
	Root?: SignalNode<T>;

	Connect(Callback: (...Args: T[]) => void): () => void;
	Wait(): promise<any, any>;
	Fire(): (...Args: T[]) => void;
	DisconnectAll(): void;
};

export default function CreateSignal<T>(): Signal<T>;
