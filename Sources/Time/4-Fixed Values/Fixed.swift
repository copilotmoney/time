import Foundation

/// A `Fixed<U>` is a type that corresponds to one (and only one) value on a physical calendar. When you think of "a calendar value", you're thinking of a `Fixed<U>`.
///
/// Some examples of fixed values are:
/// - The Reiwa era on the Japanese calendar (`Fixed<Era>`)
/// - The year 2567 BE on the Buddhist calendar (`Fixed<Year>`)
/// - The month of Magha 1945 Saka on the Indian calendar (`Fixed<Month>`)
/// - The day Shaʻban 3, 1445 AH on the Islamic calendar (`Fixed<Day>`)
/// - The hour Bahman 23, 1402 AP at 9 AM on the Persian calendar (`Fixed<Hour>`)
/// - The minute Yekatit 4, 2016 ERA1 at 9:16 AM on the Ethiopic calendar (`Fixed<Minute>`)
/// - The second February 12, 113 Minguo at 9:16:53 AM on the Republic of China calendar (`Fixed<Second>`)
/// - The nanosecond February 12, 2024 at 9:16:53.423182374  AM on the Gregorian calendar (`Fixed<Nanosecond>`)
///
/// All `Fixed` values have a ``Region``, which defines the calendar, time zone, and
/// locale used in computing the underlying component values.
///
/// Varying amounts of functionality are available to `Fixed` values depending on its **granularity**
/// and some methods and properties may slightly alter their behavior and semantics depending on their receiver's specified unit.
///
/// Fixed values are Equatable, Hashable, Comparable, Sendable, and Codable.
public struct Fixed<Granularity: Unit & LTOEEra>: Sendable {
    
    /// The set of `Calendar.Components` represented by this particular `Fixed` value
    internal static var representedComponents: Set<Calendar.Component> {
        return Calendar.Component.from(lower: Granularity.self, to: Era.self)
    }
    
    /// The `Region` value used in computing this `Fixed` value's components.
    public let region: Region
    
    internal let instant: Time.Instant
    internal let dateComponents: Foundation.DateComponents
    
    /// The set of calendar components represented by this `Fixed` value.
    public var representedComponents: Set<Calendar.Component> {
        return Self.representedComponents
    }
    
    /// The `Calendar` used in computing this `Fixed` value's components, as defined by its `Region`.
    public var calendar: Calendar { return region.calendar }
    
    /// The `TimeZone` used in computing this `Fixed` value's components, as defined by its `Region`.
    public var timeZone: TimeZone { return region.timeZone }
    
    /// The `Locale` used in computing this `Fixed` value's components, as defined by its `Region`.
    public var locale: Locale { return region.locale }
    
    /// The designated initializer for all Fixed values
    ///
    /// All initializers must funnel through this one. By the time this is called, the components should already be extracted
    internal init(region: Region, instant: Instant, components: Foundation.DateComponents) {
        self.region = region.snapshot(forced: false)
        self.instant = instant
        self.dateComponents = components
    }
    
    /// Construct a `Fixed` value from an instantaneous point in time.
    /// - Parameter region: The `Region` in which to interpret the point in time
    /// - Parameter instant: The `Instant` that is contained by the constructed `Fixed` value
    public init(region: Region, instant: Instant) {
        let dateComponents = region.calendar.dateComponents(in: region.timeZone, from: instant.date)
                                            .restrict(to: Self.representedComponents)
        self.init(region: region, instant: instant, components: dateComponents)
    }
    
    /// Construct a `Fixed` value from an instantaneous point in time.
    /// - Parameter region: The `Region` in which to interpret the point in time
    /// - Parameter instant: The `Date` that is contained by the constructed `Fixed` value
    public init(region: Region, date: Foundation.Date) {
        let dateComponents = region.calendar.dateComponents(in: region.timeZone, from: date)
                                            .restrict(to: Self.representedComponents)
        self.init(region: region, instant: Instant(date: date), components: dateComponents)
    }
    
    /// Construct a `Fixed` value from a set of `DateComponents`.
    ///
    /// This method is "strict" because it is fairly easy for it to produce an error.
    /// For example, if you are attempting to construct an `Fixed<Month>` but only provide
    /// a `year` value in the `DateComponents`, then this will throw a `TimeError`.
    ///
    /// If you are attempting to construct a calendrically impossible date, such as "February 30th",
    /// then this will throw a `TimeError`.
    ///
    /// The matching done on the `DateComponents` is a *strict* match; the returned `Fixed` value will
    /// either exactly match the provided components, or this will throw a `TimeError`.
    ///
    /// - Parameter region: The `Region` in which to interpret the date components
    /// - Parameter strictDateComponents: The `DateComponents` describing the desired calendrical date
    public init(region: Region, strictDateComponents: DateComponents) throws {
        let (date, actualComponents) = try region.calendar.exactDate(from: strictDateComponents,
                                                                     in: region.timeZone,
                                                                     matching: Self.representedComponents)
        self.init(region: region, instant: Instant(date: date), components: actualComponents)
    }
    
}

extension Fixed: Comparable {
    
    /// Determine if one `Fixed` value is greater than another `Fixed` value.
    ///
    /// A `Fixed` value is greater than another if they have the same `Region`, and the first's
    /// calendrical components come *after* the other's components.
    /// - Parameter lhs: a `Fixed` value
    /// - Parameter rhs: a `Fixed` value
    public static func > (lhs: Self, rhs: Self) -> Bool {
        guard lhs.region == rhs.region else { return false }
        
        // since we're comparing two Fixed values of the same granularity,
        // we can confidently retrieve their respective `firstInstants` and compare those
        return lhs.firstInstant > rhs.firstInstant
    }
    
    /// Determine if one `Fixed` value is less than another `Fixed` value.
    ///
    /// A `Fixed` value is less than another if they have the same `Region`, and the first's
    /// calendrical components come *before* the other's components.
    /// - Parameter lhs: a `Fixed` value
    /// - Parameter rhs: a `Fixed` value
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.region == rhs.region else { return false }
        
        return lhs.firstInstant < rhs.firstInstant
    }
    
}

extension Fixed: CustomStringConvertible, CustomDebugStringConvertible {
    
    /// Provide a description of the `Fixed` value.
    ///
    /// The description is a localized "natural" formatting of the calendar value.
    public var description: String {
        let style = FixedFormat<Granularity>(naturalFormats: calendar)
        return format(style)
    }
    
    public var debugDescription: String {
        return "Fixed<\(Granularity.self)>{ " + [
            "timestamp: \(instant.debugDescription)",
            "components: \(dateComponents.loggingDescription)",
            "locale: \(locale.loggingDescription)",
            "calendar: \(calendar.loggingDescription)",
            "timeZone: \(timeZone.identifier)"
        ].joined(separator: ", ") + " }"
    }
    
}
