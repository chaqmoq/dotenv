@testable import DotEnv
import XCTest

final class CacheTests: XCTestCase {
    func testInit() {
        // Act
        let cache = Cache<String, String>()

        // Assert
        XCTAssertEqual(cache.costLimit, 0)
        XCTAssertEqual(cache.countLimit, 0)

        // Arrange
        let costLimit = 1
        let countLimit = 2

        // Act
        cache.costLimit = costLimit
        cache.countLimit = countLimit

        // Assert
        XCTAssertEqual(cache.costLimit, costLimit)
        XCTAssertEqual(cache.countLimit, countLimit)
    }
}
