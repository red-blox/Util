/**
 * Stops the clock.
 */
declare function Stop(): void;

/**
 * Calls a function on consistent intervals.
 * This function will call the given callback every `Interval` seconds. It returns a function that can be called to stop the clock.
 * ```ts
 * const Stop = Clock(1, () => {
 *     print("Hello!");
 * });
 *
 * // Prints "Hello!" every second for 5 seconds.
 * Stop();
 * ```
 * @param Interval Interval
 * @param Callback Callback
 */
declare function Clock(Interval: number, Callback: () => void): typeof Stop;

export = Clock;
