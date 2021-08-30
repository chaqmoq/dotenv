@testable import DotEnv
import XCTest

final class FileErrorTests: XCTestCase {
    func testInit() {
        // Act
        let error = FileError()

        // Assert
        XCTAssertEqual(
            error.message,
            "\(String(describing: FileError.self)): \(ErrorType.unknownedError)"
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithMessageAndFilePath() {
        // Arrange
        let message = ErrorType.invalidFile.message
        let filePath = "/"

        // Act
        let error = FileError(message, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)"] \(String(describing: FileError.self)): \(message)
        """
        )
        XCTAssertEqual(error.filePath, error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithErrorTypeAndFilePath() {
        // Arrange
        let message = ErrorType.invalidFile.message
        let filePath = "/"

        // Act
        let error = FileError(.invalidFile, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)"] \(String(describing: FileError.self)): \(message)
        """
        )
        XCTAssertEqual(error.filePath, error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class SyntaxErrorTests: XCTestCase {
    func testInit() {
        // Arrange
        let line = 1
        let column = 1

        // Act
        let error = SyntaxError(line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(ErrorType.unknownedError)
        """
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithMessageAndFilePath() {
        // Arrange
        let line = 1
        let column = 1
        let message = ErrorType.invalidVariable("DATABASE_USER").message
        let filePath = "/"

        // Act
        let error = SyntaxError(message, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(message)
        """
        )
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithErrorTypeAndFilePath() {
        // Arrange
        let line = 1
        let column = 1
        let errorType = ErrorType.invalidVariable("DATABASE_USER")
        let message = errorType.message
        let filePath = "/"

        // Act
        let error = SyntaxError(errorType, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(message)
        """
        )
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}
