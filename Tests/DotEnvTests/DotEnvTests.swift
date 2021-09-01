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
}
