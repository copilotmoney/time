import Foundation
import XCTest

@testable import Time

class ThreadingTests: XCTestCase {

    static var allTests = [
        ("testMultithreadingWithCopies", testMultithreadingWithCopies)
    ]

    func testMultithreadingWithCopies() async throws {
        // `Calendar`/`NSCalendar` aren't thread-safe on Linux, and many `TimePeriod` operations that don't
        // appear to be mutating do end up calling calendar methods that perform temporary mutations internally.
        // A `forceCopy()` method was added to `Region` and `TimePeriod` to allow users of this library to create
        // thread-local copies.

        let region = Region(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(identifier: "Europe/Paris")!,
            locale: Locale(identifier: "en_US")
        )

        let rangeStart = try Fixed<Minute>(
            region: region,
            year: 2023,
            month: 06,
            day: 26,
            hour: 14,
            minute: 00
        )

        let results = await withTaskGroup(
            of: Range<Fixed<Minute>>.self,
            body: { group in
                for _ in 0..<1000 {
                    let taskLocalStart = rangeStart._forcedCopy()
                    // ^ Without this copy, this test is likely to crash on Linux.
                    group.addTask {
                        let fourHoursLater = taskLocalStart.adding(hours: 4)
                        if fourHoursLater <= taskLocalStart {
                            print(taskLocalStart.debugDescription, fourHoursLater.debugDescription)
                        }
                        let range = taskLocalStart..<fourHoursLater
                        XCTAssert(range.lowerBound <= range.upperBound)
                        // ^ This assert is technially redundant since `Range` will crash if that assertion would fail.
                        return range
                    }
                }

                var ranges = [Range<Fixed<Minute>>]()
                for await result in group { ranges.append(result) }
                return ranges
            }
        )

        XCTAssertEqual(results.count, 1000)
    }

}
