@testable import DotEnv
import XCTest

final class FileTests: XCTestCase {
    let source = """
    DATABASE_USER=root
    DATABASE_PASSWORD=password
    """

    func testInitWithStringLiteral() {
        // Act
        let file = File(stringLiteral: source)

        // Assert
        XCTAssertEqual(file.source, source)
        XCTAssertEqual(file.description, source)
        XCTAssertNil(file.path)
    }
}
