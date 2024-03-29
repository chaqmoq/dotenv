@testable import DotEnv
import XCTest

final class FileErrorTests: XCTestCase {
    let filePath = "/.env"

    func testInit() {
        // Act
        let error = FileError()

        // Assert
        XCTAssertEqual(
            error.message,
            "\(String(describing: FileError.self)): \(ErrorType.unknownError)"
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithMessageAndFilePath() {
        // Arrange
        let message = ErrorType.fileNotFound.message

        // Act
        let error = FileError(message, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)"] \(String(describing: FileError.self)): \(message)
        """)
        XCTAssertEqual(error.filePath, error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithErrorTypeAndFilePath() {
        // Arrange
        let errorType = ErrorType.fileNotFound
        let message = errorType.message

        // Act
        let error = FileError(errorType, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)"] \(String(describing: FileError.self)): \(message)
        """)
        XCTAssertEqual(error.filePath, error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
        XCTAssertEqual(error, fileError(errorType, filePath: filePath))
    }
}

final class SyntaxErrorTests: XCTestCase {
    let filePath = "/.env"

    func testInit() {
        // Arrange
        let line = 1
        let column = 1

        // Act
        let error = SyntaxError(line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(ErrorType.unknownError)
        """)
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithMessageAndFilePath() {
        // Arrange
        let line = 1
        let column = 1
        let message = ErrorType.invalidVariableValue("DATABASE_USER").message

        // Act
        let error = SyntaxError(message, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(message)
        """)
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }

    func testInitWithErrorTypeAndFilePath() {
        // Arrange
        let line = 1
        let column = 1
        let errorType = ErrorType.invalidVariableValue("DATABASE_USER")
        let message = errorType.message

        // Act
        let error = SyntaxError(errorType, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [File: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(message)
        """)
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
        XCTAssertEqual(error, syntaxError(errorType, filePath: filePath, line: line, column: column))
    }
}

final class ErrorTypeTests: XCTestCase {
    func testCases() {
        // Arrange
        let invalidCharacter = "1"
        let variable = "DATABASE_USER"

        // Assert
        XCTAssertEqual(ErrorType.fileNotEncodable.message, ErrorType.fileNotEncodable.errorDescription)
        XCTAssertEqual(ErrorType.fileNotEncodable.message, "An environment file is not encodable.")
        XCTAssertEqual(ErrorType.fileNotFound.message, ErrorType.fileNotFound.errorDescription)
        XCTAssertEqual(ErrorType.fileNotFound.message, "An environment file is not found.")
        XCTAssertEqual(
            ErrorType.invalidVariableName(invalidCharacter).message,
            ErrorType.invalidVariableName(invalidCharacter).errorDescription
        )
        XCTAssertEqual(
            ErrorType.invalidVariableName(invalidCharacter).message,
            """
            An invalid character "\(invalidCharacter)" in a variable. A variable must be alphanumeric and must \
            start with a letter.
            """
        )
        XCTAssertEqual(
            ErrorType.invalidVariableValue(variable).message,
            ErrorType.invalidVariableValue(variable).errorDescription
        )
        XCTAssertEqual(
            ErrorType.invalidVariableValue(variable).message,
            """
            A variable "\(variable)" must have a value or a suffix "\(Token.equal.rawValue)" to denote its value is \
            empty.
            """
        )
        XCTAssertEqual(ErrorType.unknownError.message, ErrorType.unknownError.errorDescription)
        XCTAssertEqual(ErrorType.unknownError.message, "An unknown error.")
        XCTAssertEqual(ErrorType.unterminatedString.message, ErrorType.unterminatedString.errorDescription)
        XCTAssertEqual(ErrorType.unterminatedString.message, "An unterminated string.")
    }
}
