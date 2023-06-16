/**
 * Creates a new Clock. The returned function can be called to stop it.
 * ```ts
 * const Stop = Clock(1, () => {
 *     print("Hello!");
 * });
 *
 * // Prints "Hello!" every second for 5 seconds.
 * Stop();
 * ```
 * @param Interval Every how many seconds the callback should be called
 * @param Callback Callback
 */
export function Clock(Interval: number, Callback: () => void): () => void;
