@testable import DotEnv
import XCTest

final class FileTests: XCTestCase {
    let source = """
    DATABASE_USER=root
    DATABASE=dev
    """
    let path = "/.env"

    func testInitWithStringLiteral() {
        // Act
        let file = File(stringLiteral: source)

        // Assert
        XCTAssertEqual(file.source, source)
        XCTAssertEqual(file.description, source)
        XCTAssertNil(file.path)
    }

    func testInitWithPath() {
        // Act
        let file = File(source, path: path)

        // Assert
        XCTAssertEqual(file.source, source)
        XCTAssertEqual(file.description, source)
        XCTAssertEqual(file.path, path)
    }
}
