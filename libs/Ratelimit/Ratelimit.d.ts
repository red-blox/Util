declare function Ratelimit<T>(Limit: number, Interval: number): (Key?: T) => boolean;
