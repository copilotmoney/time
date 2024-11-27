import Time
import XCTest

class DurationTests: XCTestCase {

    static var allTests = [
        ("testAritmetics", testAritmetics),
        ("testInPlaceAritmetics", testInPlaceAritmetics),
        ("testConversions", testConversions),
    ]

    func testAritmetics() throws {
        let duration = Duration.seconds(1)

        XCTAssertEqual(duration / (2 as Int), Duration.seconds(0.5))
        XCTAssertEqual(duration / (0.5 as Double), Duration.seconds(2))
        XCTAssertEqual(duration / duration, Double(1))
        XCTAssertEqual(duration * 2, Duration.seconds(2))
        XCTAssertEqual(duration / 0.5, Duration.seconds(2))
        XCTAssertEqual(duration * (0.5 as Double), Duration.seconds(0.5))
        XCTAssertEqual(duration * (5 as Int), Duration.seconds(5))

        XCTAssertEqual(Duration.seconds(0.1) + Duration.seconds(0.2), Duration.seconds(0.3))
        XCTAssertEqual(Duration.seconds(0.3) - Duration.seconds(0.2), Duration.seconds(0.1))
        XCTAssertEqual(-duration, Duration(secondsComponent: -1, attosecondsComponent: 0))
    }

    func testInPlaceAritmetics() throws {
        var duration = Duration.seconds(1)

        duration /= 0.25 as Double
        XCTAssertEqual(duration, Duration.seconds(4))

        duration = Duration.seconds(1)
        duration /= 4 as Int
        XCTAssertEqual(duration, Duration.seconds(0.25))

        duration = Duration.seconds(1)
        duration *= 3
        XCTAssertEqual(duration, Duration.seconds(3))
    }

    func testConversions() throws {
        XCTAssertEqual(Duration.seconds(2 as Double), Duration.seconds(2 as Int))
        XCTAssertEqual(Duration.seconds(0.5 as Double), Duration.milliseconds(500 as Int))
        XCTAssertEqual(Duration.milliseconds(0.5 as Double), Duration.microseconds(500 as Int))
        XCTAssertEqual(Duration.microseconds(0.5 as Double), Duration.nanoseconds(500 as Int))
    }

    func testCodable() throws {
        let duration = Duration.seconds(4.5)

        let encoded = try JSONEncoder().encode(duration)
        let decoded = try JSONDecoder().decode(Duration.self, from: encoded)

        XCTAssertEqual(decoded, duration)
    }
}
