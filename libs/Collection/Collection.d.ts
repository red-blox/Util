/**
 * Calls all cleanup functions and stops the collection.
 */
declare function Stop(): void;

/**
 * Handles instance addition and removal from collections.
 * ```ts
 * const Stop = Collection("Tag", (Instance: Instance) => {
 *     print("Tag added");
 *     return () => {
 *         print("Tag removed");
 *     }
 * });
 *
 * // After 10 seconds calls all cleanup functions and stops the collection.
 * task.wait(10);
 * Stop();
 * ```
 * @param Tag Tag
 * @param Start Callback, called for every instance that has the tag & any that have it added
 */
declare function Collection(Tag: string, Start: (Instance: Instance) => () => void | void): typeof Stop;

export = Collection;
