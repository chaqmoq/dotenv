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

    func testSetGet() {
        // Arrange
        let cache = Cache<String, String>()
        let key1 = "key1"
        let value1 = "value1"
        let key2 = "key2"
        let value2 = "value2"

        // Act
        cache.setValue(value1, forKey: key1)

        // Assert
        XCTAssertEqual(cache.getValue(forKey: key1), value1)

        // Act
        cache.setValue(value2, forKey: key2)

        // Assert
        XCTAssertEqual(cache.getValue(forKey: key1), value1)
        XCTAssertEqual(cache.getValue(forKey: key2), value2)

        // Act
        cache.removeValue(forKey: key1)

        // Assert
        XCTAssertNil(cache.getValue(forKey: key1))
        XCTAssertEqual(cache.getValue(forKey: key2), value2)

        // Act
        cache.clear()

        // Assert
        XCTAssertNil(cache.getValue(forKey: key1))
        XCTAssertNil(cache.getValue(forKey: key2))
    }
}
