/**
 * Takes a key and returns whether or not the key has been used more than the limit.
 * @param Key Optional
 */
declare function LimitCheck<T>(Key?: T): boolean;

/**
 * Ratelimits many keys in a very intuitive interface.
 * This function takes a limit and interval for resetting said limit, and returns a function that takes a key and returns whether or not the key has been used more than the limit.
 
 You can also use the function without a key.
 * ```ts
 * // 3 calls per 10 seconds
 * const LimitCheck = Ratelimit<string>(3, 10);
 * LimitCheck("Key1"); // true
 * LimitCheck("Key1"); // true
 * LimitCheck("Key1"); // true
 * LimitCheck("Key1"); // false
 * ```
 * @param Limit
 * @param Interval
 */
export function Ratelimit<T>(Limit: number, Interval: number): typeof LimitCheck;
