import Foundation

/// A namespace for retrieving commonly-used clocks
@available(iOS 16, macOS 13, tvOS 16, watchOS 9, macCatalyst 16, *)
public enum Clocks {

    /// The system clock. This clock uses the current `Region` and follows the current device time.
    public static let system: any RegionalClock = SystemClock(region: .autoupdatingCurrent)

    /// A POSIX clock. This clock uses the POSIX `Region` and follows the current device time.
    public static let posix: any RegionalClock = SystemClock(region: .posix)

    /// Create a clock that follows the current device time,
    /// but produces calendar values according to the specified `Region`.
    public static func system(in region: Region) -> any RegionalClock {
        return SystemClock(region: region)
    }

    /// Create a ``RegionalClock`` with a custom start time and flow rate.
    ///
    /// - Parameter referenceDate: The instantaneous "now" from which the clock will start counting.
    /// - Parameter rate: The rate at which time progresses in the clock, relative to the supplied calendar.
    ///   `1.0` (the default) means one second on the system clock correlates to a second passing in the clock.
    ///   `2.0` would mean that every second elapsing on the system clock would be 2 seconds on this clock (ie, time progresses twice as fast).
    /// - Parameter region: The ``Region`` in which calendar values are produced.
    ///
    /// - Note: The `rate` must be strictly greater than `0`. A value less than or equal to `0` will cause a crash.
    public static func custom(
        startingFrom referenceInstant: Instant,
        rate: Double = 1.0,
        region: Region = .autoupdatingCurrent
    ) -> any RegionalClock {
        guard rate > 0 else {
            fatalError("You cannot create a clock where time has stopped or flows backwards")
        }

        return CustomClock(
            referenceInstant: referenceInstant,
            rate: rate,
            region: region
        )
    }

    /// Create a clock with a custom start time and flow rate.
    ///
    /// - Parameter referenceEpoch: The instantaneous "now" from which the clock will start counting.
    /// - Parameter rate: The rate at which time progresses in the clock, relative to the supplied calendar.
    ///     `1.0` (the default) means one second on the system clock correlates to a second passing in the clock.
    ///     `2.0` would mean that every second elapsing on the system clock would be 2 seconds on this clock (ie, time progresses twice as fast).
    /// - Parameter region: The `Region` in which calendar values are produced.
    ///
    /// - Note: The `rate` must be strictly greater than `0`. A value less than or equal to `0` will cause a crash.
    public static func custom(
        startingFrom referenceEpoch: Epoch,
        rate: Double = 1.0,
        region: Region = .autoupdatingCurrent
    ) -> any RegionalClock {
        let referenceInstant = Instant(interval: 0, since: referenceEpoch)
        return self.custom(startingFrom: referenceInstant, rate: rate, region: region)
    }
}
