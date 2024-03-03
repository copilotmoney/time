import Foundation

internal protocol Format {
    var template: String { get }
}

extension Fixed {
    
    static func naturalFormats(in calendar: Calendar) -> Array<Format?> {
        var f = Array<Format?>()
        
        let order = Calendar.Component.descendingOrder
        let represented = Self.representedComponents
        var hasTime = false
        
        for unit in order {
            guard represented.contains(unit) else { continue }
            switch unit {
                case .era:
                    if calendar.isEraRelevant { f.append(Template<Era>.abbreviated) }
                case .year: 
                    f.append(Template<Year>.naturalDigits)
                case .month:
                    f.append(Template<Month>.naturalName)
                case .day:
                    f.append(Template<Weekday>.naturalName)
                    f.append(Template<Day>.naturalDigits)
                case .hour: 
                    f.append(Template<Hour>.naturalDigits)
                    hasTime = true
                case .minute:
                    f.append(Template<Minute>.naturalDigits)
                    hasTime = true
                case .second:
                    f.append(Template<Second>.naturalDigits)
                    hasTime = true
                case .nanosecond:
                    f.append(Template<Nanosecond>.digits(4))
                    hasTime = true
                default: 
                    continue
            }
        }
        
        if hasTime {
            f.append(Template<TimeZone>.shortSpecific)
        }
        
        return f
    }
    
    internal func dateForFormatting() -> Date {
        return firstInstant.date
    }
    
}
