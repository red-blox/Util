/**
 * A shared "fast spawn" function that reuses threads.
 * This utility is used to spawn a function in a new thread. It is similar to `task.spawn`, but doesn't return a thread, and instead reuses a thread if possible. This has been benchmarked many times to produce a significant performance increase.
 * ```ts
 * Spawn(() => {
 *     while (true) {
 *         print("Hello, World!");
 *         task.wait(1);
 *     }
 * });
 *
 * Spawn<string>(print, "Hello", "World!");
 * ```
 * @param Callback
 * @param Args
 */
export function Spawn<T>(Callback: (...Args: T[]) => void, ...Args: T[]): void;
