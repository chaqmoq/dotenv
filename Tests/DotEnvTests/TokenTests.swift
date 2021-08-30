@testable import DotEnv
import XCTest

final class TokenTests: XCTestCase {
    func testCases() {
        // Assert
        XCTAssertEqual(Token.carriageReturn.rawValue, "\r")
        XCTAssertEqual(Token.comment.rawValue, "#")
        XCTAssertEqual(Token.equal.rawValue, "=")
        XCTAssertEqual(Token.eof.rawValue, "\0")
        XCTAssertEqual(Token.newline.rawValue, "\n")
        XCTAssertEqual(Token.quote.rawValue, "\"")
        XCTAssertEqual(Token.tab.rawValue, "\t")
        XCTAssertEqual(Token.whitespace.rawValue, " ")
    }
}
