/* eslint-disable @typescript-eslint/no-explicit-any */
import { promise } from "@redblox/promise";

type SignalNode<T> = {
	Next?: SignalNode<T>;
	Callback: (Value: T) => void;
};

/**
 * Disconnects from the Signal.
 */
declare function Disconnect(): void;

type SignalObject<T> = {
	Root?: SignalNode<T>;

	/**
	 * Connects the listener to the Signal and returns a function that can be used to disconnect the listener from the signal. Listeners are passed all fired values.
	 *
	 * `Connect` passes a return function to allow easy use with utilities such as Bin, and to reduce bloat.
	 * ```ts
	 * const Disconnect = Signal.Connect((...Values: unknown[]) => {
	 *     print(...Values);
	 * });
	 *
	 * Signal.Fire("Hello, World!"); // "Hello, World!"
	 * Disconnect();
	 * Signal.Fire("Hello, World!"); // No output.
	 * ```
	 * @param Callback
	 */
	Connect(Callback: (...Args: T[]) => void): typeof Disconnect;

	/**
	 * Returns a Promise that resolves when the Signal is next fired. The Promise will resolve with all values fired.
	 * ```ts
	 * Signal.Wait().Then(print).Await();
	 * ```
	 */
	Wait(): promise<any, any>;

	/**
	 * Fires the passed values to all connected listeners.
	 * ```ts
	 * Signal.Fire("Hello, World!");
	 *
	 * // You can also fire multiple values
	 * Signal.Fire("Hello", "World!", 15, true);
	 * ```
	 */
	Fire(...Args: T[]): void;

	/**
	 * Disconnects all listeners from the Signal, enabling it to be garbage collected.
	 */
	DisconnectAll(): void;
};

/**
 * A signal implementation without connection objects.
 *
 * Creates & returns a new Signal object, which can be used to fire any number of events and listen to them in any number of callbacks.
 *
 * ```ts
 * const LogSignal = Signal<unknown>();
 *
 * LogSignal.Connect((...Values: unknown[]) => {
 *     print(...Values);
 * });
 *
 * LogSignal.Fire("Hello, World!");
 */
declare function Signal<T>(): SignalObject<T>;

declare namespace Signal {
	export { SignalObject as Signal, SignalNode };
}

export = Signal;
