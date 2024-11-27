import XCTest

extension XCTestCase {

    func wait(_ delay: TimeInterval) {
        let e = self.expectation(description: "Wait for \(delay)s")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { e.fulfill() }
        self.wait(for: [e], timeout: delay + 0.1)
    }

    func skipIfUnavailable(file: StaticString = #file, line: UInt = #line) throws {
        if #unavailable(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, macCatalyst 16.0) {
            try XCTSkipIf(true,"Skipping unavailable test.", file: file, line: line)
        }
    }
}

class SkipUnavailableTestCase: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        try skipIfUnavailable()
    }
}
