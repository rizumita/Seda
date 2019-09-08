import XCTest
@testable import Seda

final class SedaTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Seda().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
