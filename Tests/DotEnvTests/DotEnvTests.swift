@testable import DotEnv
import XCTest

final class DotEnvTests: XCTestCase {
    let env = DotEnv()
    let nonExistingFilePath = "/non-existing.env"

    override func setUp() {
        super.setUp()

        env.reset()
    }

    func testReadingNonExistingFile() {
        // Act/Assert
        XCTAssertThrowsError(try env.readFile(at: nonExistingFilePath)) { error in
            XCTAssertTrue(error is FileError)
            XCTAssertEqual(error.localizedDescription, """
            [File: "\(nonExistingFilePath)"] \(String(describing: FileError.self)): \(ErrorType.fileNotFound.message)
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
        let filePath = "\(Bundle.module.resourcePath!)/env.invalid"
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

    func testParsingAndCachingFileAndVariables() {
        // Arrange
        let filePath = "\(Bundle.module.resourcePath!)/env"
        var variables: [String: String]?

        // Act/Assert
        XCTAssertNoThrow(variables = try env.parseFile(at: filePath))
        XCTAssertEqual(variables?.count, 9)
        XCTAssertEqual(variables?["EMTPY"], "")
        XCTAssertEqual(variables?["QUOTED"], "quoted")
        XCTAssertEqual(variables?["QUOTED_WITH_WHITESPACE"], " quoted with whitespace ")
        XCTAssertEqual(variables?["MULTI_LINE"], "multi\nline")
        XCTAssertEqual(variables?["UNQUOTED"], "unquoted")
        XCTAssertEqual(variables?["UNQUOTED_WITH_WHITESPACE"], "unquoted with whitespace")
        XCTAssertEqual(variables?["DICTIONARY"], "{\"key\": \"value\"}")
        XCTAssertEqual(variables?["PATH"], "/path/to")
        XCTAssertEqual(variables?["lowercased"], "lowercased")

        // Act/Assert
        XCTAssertNoThrow(variables = try env.parseFile(at: filePath))
        XCTAssertEqual(variables?.count, 9)
        XCTAssertEqual(variables?["EMTPY"], "")
        XCTAssertEqual(variables?["QUOTED"], "quoted")
        XCTAssertEqual(variables?["QUOTED_WITH_WHITESPACE"], " quoted with whitespace ")
        XCTAssertEqual(variables?["MULTI_LINE"], "multi\nline")
        XCTAssertEqual(variables?["UNQUOTED"], "unquoted")
        XCTAssertEqual(variables?["UNQUOTED_WITH_WHITESPACE"], "unquoted with whitespace")
        XCTAssertEqual(variables?["DICTIONARY"], "{\"key\": \"value\"}")
        XCTAssertEqual(variables?["PATH"], "/path/to")
        XCTAssertEqual(variables?["lowercased"], "lowercased")

        // Act
        env.clearCache()

        // Act/Assert
        XCTAssertNoThrow(variables = try env.parseFile(at: filePath))
        XCTAssertEqual(variables?.count, 9)
        XCTAssertEqual(variables?["EMTPY"], "")
        XCTAssertEqual(variables?["QUOTED"], "quoted")
        XCTAssertEqual(variables?["QUOTED_WITH_WHITESPACE"], " quoted with whitespace ")
        XCTAssertEqual(variables?["MULTI_LINE"], "multi\nline")
        XCTAssertEqual(variables?["UNQUOTED"], "unquoted")
        XCTAssertEqual(variables?["UNQUOTED_WITH_WHITESPACE"], "unquoted with whitespace")
        XCTAssertEqual(variables?["DICTIONARY"], "{\"key\": \"value\"}")
        XCTAssertEqual(variables?["PATH"], "/path/to")
        XCTAssertEqual(variables?["lowercased"], "lowercased")
    }

    func testLoadingFile() {
        // Arrange
        let file: File = """
        DATABASE_USER=root
        DATABASE=dev
        """

        // Act/Assert
        XCTAssertNoThrow(try env.load(file))
        XCTAssertEqual(env.all["DATABASE_USER"], "root")
        XCTAssertEqual(env.all["DATABASE"], "dev")
    }

    func testLoadingFileAtPath() {
        // Arrange
        let filePath = "\(Bundle.module.resourcePath!)/env"

        // Act/Assert
        XCTAssertNoThrow(try env.load(at: filePath))
        XCTAssertEqual(env.all["EMTPY"], "")
        XCTAssertEqual(env.all["QUOTED"], "quoted")
        XCTAssertEqual(env.all["QUOTED_WITH_WHITESPACE"], " quoted with whitespace ")
        XCTAssertEqual(env.all["MULTI_LINE"], "multi\nline")
        XCTAssertEqual(env.all["UNQUOTED"], "unquoted")
        XCTAssertEqual(env.all["UNQUOTED_WITH_WHITESPACE"], "unquoted with whitespace")
        XCTAssertEqual(env.all["DICTIONARY"], "{\"key\": \"value\"}")
        XCTAssertEqual(env.all["PATH"], "/path/to")
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
        var configuration = DotEnv.Configuration.Caching()

        // Assert
        XCTAssertEqual(configuration.costLimit, 0)
        XCTAssertEqual(configuration.countLimit, 0)
        XCTAssertTrue(configuration.isEnabled)

        // Arrange
        let costLimit = 1
        let countLimit = 2
        let isEnabled = false

        // Act
        configuration = DotEnv.Configuration.Caching(
            costLimit: costLimit,
            countLimit: countLimit,
            isEnabled: isEnabled
        )

        // Assert
        XCTAssertEqual(configuration.costLimit, costLimit)
        XCTAssertEqual(configuration.countLimit, countLimit)
        XCTAssertEqual(configuration.isEnabled, isEnabled)
    }
}
