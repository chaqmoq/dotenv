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
            """)
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
            """)
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
            """)
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
            """)
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
        XCTAssertEqual(env.all["MULTI_LINE"], "multi\nline")
        XCTAssertEqual(env.all["UNQUOTED"], "unquoted")
        XCTAssertEqual(env.all["UNQUOTED_WHITESPACE"], "unquoted whitespace")
        XCTAssertEqual(env.all["DICTIONARY"], "{\"key\": \"value\"}")
        XCTAssertEqual(env.all["FILE_PATH"], "/to/path")
        XCTAssertEqual(env.all["lowercased"], "lowercased")
    }

    func testSettingVariable() {
        // Arrange
        let key1 = "KEY1"
        let value1 = "value1"
        let key2 = "KEY2"
        let value2: String? = nil
        let key3 = "KEY3"
        let value3 = "value3"
        let key4 = "KEY4"

        // Act
        env.set(value1, forKey: key1)
        env.set(value2, forKey: key2)
        env[key3] = value3

        // Assert
        XCTAssertEqual(env.get(key1), value1)
        XCTAssertEqual(env.get(key2), "")
        XCTAssertEqual(env[key3], value3)
        XCTAssertNil(env.get(key4))

        // Act
        env.set(value3, forKey: key2, overwrite: false)

        // Assert
        XCTAssertEqual(env.get(key2), "")
    }
}

final class DotEnvConfigurationTests: XCTestCase {
    func testInit() {
        // Act
        var configuration = DotEnv.Configuration()

        // Assert
        XCTAssertEqual(configuration.caching.costLimit, 0)
        XCTAssertEqual(configuration.caching.countLimit, 0)
        XCTAssertTrue(configuration.caching.isEnabled)

        // Arrange
        let costLimit = 1
        let countLimit = 2
        let isEnabled = false

        // Act
        configuration = DotEnv.Configuration(
            caching: .init(costLimit: costLimit, countLimit: countLimit, isEnabled: isEnabled)
        )

        // Assert
        XCTAssertEqual(configuration.caching.costLimit, costLimit)
        XCTAssertEqual(configuration.caching.countLimit, countLimit)
        XCTAssertEqual(configuration.caching.isEnabled, isEnabled)
    }
}

final class DotEnvCachingConfigurationTests: XCTestCase {
    func testInit() {
        // Act
        var configuration = DotEnv.CachingConfiguration()

        // Assert
        XCTAssertEqual(configuration.costLimit, 0)
        XCTAssertEqual(configuration.countLimit, 0)
        XCTAssertTrue(configuration.isEnabled)

        // Arrange
        let costLimit = 1
        let countLimit = 2
        let isEnabled = false

        // Act
        configuration = DotEnv.CachingConfiguration(costLimit: costLimit, countLimit: countLimit, isEnabled: isEnabled)

        // Assert
        XCTAssertEqual(configuration.costLimit, costLimit)
        XCTAssertEqual(configuration.countLimit, countLimit)
        XCTAssertEqual(configuration.isEnabled, isEnabled)
    }
}
