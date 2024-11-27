import Foundation

public struct Duration: Sendable {
    public var secondsComponent: Int64
    public var attosecondsComponent: Int64

    public init(secondsComponent: Int64, attosecondsComponent: Int64) {
        self.secondsComponent = secondsComponent
        self.attosecondsComponent = attosecondsComponent
    }

    public static func ... (minimum: Duration, maximum: Duration) -> ClosedRange<Duration> {
        ClosedRange(uncheckedBounds: (minimum, maximum))
    }

    public static func += (lhs: inout Duration, rhs: Duration) {
        lhs = lhs + rhs
    }

    public static func -= (lhs: inout Duration, rhs: Duration) {
        lhs = lhs - rhs
    }

    prefix public static func + (x: Duration) -> Duration {
        .zero + x
    }

    public static func ..< (minimum: Duration, maximum: Duration) -> Range<Duration> {
        Range(uncheckedBounds: (minimum, maximum))
    }

    prefix public static func ..< (maximum: Duration) -> PartialRangeUpTo<Duration> {
        PartialRangeUpTo(maximum)
    }

    prefix public static func ... (maximum: Duration) -> PartialRangeThrough<Duration> {
        PartialRangeThrough(maximum)
    }

    postfix public static func ... (minimum: Duration) -> PartialRangeFrom<Duration> {
        PartialRangeFrom(minimum)
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    var realDuration: Swift.Duration {
        .init(secondsComponent: secondsComponent, attosecondsComponent: attosecondsComponent)
    }
}

extension Duration {
    public var components: (seconds: Int64, attoseconds: Int64) {
        (seconds: secondsComponent, attoseconds: attosecondsComponent)
    }
}

extension Duration {
    @inlinable public static func seconds<T>(_ seconds: T) -> Duration where T: BinaryInteger {
        .init(secondsComponent: Int64(seconds), attosecondsComponent: 0)
    }

    public static func seconds(_ seconds: Double) -> Duration {
        let intSeconds = Int64(seconds)
        let attoseconds = Int64((seconds - Double(intSeconds)) * 1_000_000_000_000_000_000)
        return .init(secondsComponent: intSeconds, attosecondsComponent: attoseconds)
    }

    @inlinable public static func milliseconds<T>(_ milliseconds: T) -> Duration
    where T: BinaryInteger {
        let intSeconds = Int64(milliseconds - (milliseconds % 1000))
        let attoseconds = Int64((milliseconds % 1000) * 1_000_000_000_000_000)
        return .init(secondsComponent: intSeconds, attosecondsComponent: attoseconds)
    }

    public static func milliseconds(_ milliseconds: Double) -> Duration {
        let intSeconds = Int64(milliseconds / 1_000)
        let attoseconds = Int64((milliseconds - Double(intSeconds) * 1_000) * 1_000_000_000_000_000)
        return .init(secondsComponent: intSeconds, attosecondsComponent: attoseconds)
    }

    @inlinable public static func microseconds<T>(_ microseconds: T) -> Duration
    where T: BinaryInteger {
        let intSeconds = Int64(microseconds - (microseconds % 1_000_000))
        let attoseconds = Int64((microseconds % 1_000_000) * 1_000_000_000_000)
        return .init(secondsComponent: intSeconds, attosecondsComponent: attoseconds)
    }

    public static func microseconds(_ microseconds: Double) -> Duration {
        let intSeconds = Int64(microseconds / 1_000_000)
        let attoseconds = Int64((microseconds - Double(intSeconds) * 1_000_000) * 1_000_000_000_000)
        return .init(secondsComponent: intSeconds, attosecondsComponent: attoseconds)
    }

    @inlinable public static func nanoseconds<T>(_ nanoseconds: T) -> Duration
    where T: BinaryInteger {
        let intSeconds = Int64(nanoseconds - (nanoseconds % 1_000_000_000))
        let attoseconds = Int64((nanoseconds % 1_000_000_000) * 1_000_000_000)
        return .init(secondsComponent: intSeconds, attosecondsComponent: attoseconds)
    }
}

extension Duration {
    public static func / (lhs: Duration, rhs: Double) -> Duration {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        return .microseconds(total / rhs / 1_000)
    }

    public static func /= (lhs: inout Duration, rhs: Double) {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        lhs = .microseconds(total / rhs / 1_000)
    }

    public static func / <T>(lhs: Duration, rhs: T) -> Duration where T: BinaryInteger {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        return .microseconds(total / Double(rhs) / 1_000)
    }

    public static func /= <T>(lhs: inout Duration, rhs: T) where T: BinaryInteger {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        lhs = .microseconds(total / Double(rhs) / 1_000)
    }

    public static func / (lhs: Duration, rhs: Duration) -> Double {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        let total2 =
            Double(rhs.secondsComponent) * 1_000_000_000 + Double(rhs.attosecondsComponent) / 1_000_000_000
        return total / total2
    }

    public static func * (lhs: Duration, rhs: Double) -> Duration {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        return .microseconds(total * rhs / 1_000)
    }

    public static func * <T>(lhs: Duration, rhs: T) -> Duration where T: BinaryInteger {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        return .microseconds(total * Double(rhs) / 1_000)
    }

    public static func *= <T>(lhs: inout Duration, rhs: T) where T: BinaryInteger {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        lhs = .microseconds(total * Double(rhs) / 1_000)
    }
}

extension Duration {
    public static func /= (lhs: inout Duration, rhs: Int) {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        lhs = .microseconds(total / Double(rhs) / 1_000)
    }

    public static func *= (lhs: inout Duration, rhs: Int) {
        let total =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        lhs = .microseconds(total * Double(rhs) / 1_000)
    }
}

extension Duration: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode([Int64].self)
        self.secondsComponent = values[0]
        self.attosecondsComponent = values[1]
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([secondsComponent, attosecondsComponent])
    }
}

extension Duration: AdditiveArithmetic {
    public static var zero: Duration {
        .seconds(0)
    }

    public static func + (lhs: Duration, rhs: Duration) -> Duration {
        let lhs =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        let rhs =
            Double(rhs.secondsComponent) * 1_000_000_000 + Double(rhs.attosecondsComponent) / 1_000_000_000
        return .microseconds((lhs + rhs) / 1_000)
    }

    public static func - (lhs: Duration, rhs: Duration) -> Duration {
        let lhs =
            Double(lhs.secondsComponent) * 1_000_000_000 + Double(lhs.attosecondsComponent) / 1_000_000_000
        let rhs =
            Double(rhs.secondsComponent) * 1_000_000_000 + Double(rhs.attosecondsComponent) / 1_000_000_000
        return .microseconds((lhs - rhs) / 1_000)
    }

    public prefix static func - (rhs: Self) -> Self {
        var copy = Duration.zero
        copy -= rhs
        return copy
    }
}

extension Duration: Hashable {}

extension Duration: Equatable {}

extension Duration: Comparable {
    public static func < (lhs: Duration, rhs: Duration) -> Bool {
        if lhs.secondsComponent == rhs.secondsComponent {
            return lhs.attosecondsComponent < rhs.attosecondsComponent
        }
        return lhs.secondsComponent < rhs.secondsComponent
    }
}

extension Duration: CustomStringConvertible {
    public var description: String {
        let total = Double(secondsComponent) * 1_000_000_000 + Double(attosecondsComponent) / 1_000_000_000
        return "\(total / 1_000_000_000)"
    }
}
