@testable import DotEnv
import XCTest

final class DotEnvTests: XCTestCase {
    let env = DotEnv()

    override func setUp() {
        super.setUp()

        env.reset()
    }

    func testReadingNonExistingFile() {
        // Arrange
        let filePath = "/non-existing.env"

        // Act/Assert
        XCTAssertThrowsError(try env.readFile(at: filePath)) { error in
            XCTAssertTrue(error is FileError)
            XCTAssertEqual(error.localizedDescription, """
            [File: "\(filePath)"] \(String(describing: FileError.self)): \(ErrorType.fileNotFound.message)
            """
            )
        }
    }

    func testParsingFileWithInvalidVariableName() {
        // Arrange
        let invalidCharacter = "1"
        let file: File = """
        1_INVALID_VARIABLE_NAME=value
        """
        let line = 1
        let column = 1

        // Act/Assert
        XCTAssertThrowsError(try env.parseFile(file)) { error in
            XCTAssertTrue(error is SyntaxError)
            XCTAssertEqual(error.localizedDescription, """
            [Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
            \(ErrorType.invalidVariableName(invalidCharacter).message)
            """
            )
        }
    }

    func testParsingFileWithInvalidVariableValue() {
        // Arrange
        let filePath = "\(Bundle.module.resourcePath!)/invalid.env"
        let file = try! env.readFile(at: filePath)
        let variable = file.source.trimmingCharacters(in: .newlines)
        let line = 1
        let column = variable.count

        // Act/Assert
        XCTAssertThrowsError(try env.parseFile(file)) { error in
            XCTAssertTrue(error is SyntaxError)
            XCTAssertEqual(error.localizedDescription, """
            [File: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
            \(ErrorType.invalidVariableValue(variable).message)
            """
            )
        }
    }

    func testParsingFileWithUnterminatedString() {
        // Arrange
        let file: File = "UNTERMINATED_STRING=\""
        let line = 1
        let column = file.source.count

        // Act/Assert
        XCTAssertThrowsError(try env.parseFile(file)) { error in
            XCTAssertTrue(error is SyntaxError)
            XCTAssertEqual(error.localizedDescription, """
            [Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
            \(ErrorType.unterminatedString.message)
            """
            )
        }
    }

    func testLoadingFile() {
        // Arrange
        let filePath = "\(Bundle.module.resourcePath!)/env"

        // Act/Assert
        XCTAssertNoThrow(try env.load(atPath: filePath))
        XCTAssertEqual(env.all["EMTPY"], "")
        XCTAssertEqual(env.all["QUOTE"], "quote")
        XCTAssertEqual(env.all["QUOTE_WHITESPACE"], " quote whitespace ")
        XCTAssertEqual(env.all["UNQUOTED"], "unquoted")
        XCTAssertEqual(env.all["UNQUOTED_WHITESPACE"], "unquoted whitespace")
        XCTAssertEqual(env.all["DICTIONARY"], "{\"key\": \"value\"}")
        XCTAssertEqual(env.all["FILE_PATH"], "/to/path")
    }
}
