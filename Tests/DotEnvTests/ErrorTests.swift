@testable import DotEnv
import XCTest

final class FileErrorTests: XCTestCase {
    func testInit() {
        // Act
        var error = FileError()

        // Assert
        XCTAssertEqual(
            error.message,
            "\(String(describing: FileError.self)): \(ErrorType.unknownedError)"
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let filePath = "/"
        let message = ErrorType.invalidFile.message

        // Act
        error = FileError(message, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)"] \(String(describing: FileError.self)): \(message)
        """
        )
        XCTAssertEqual(error.filePath, error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}
