final class Parser {
    let file: File
    private let count: Int

    private var isAtEnd: Bool { current >= count }
    private var start = 0
    private var current = 0
    private var line = 1
    private var column = 0
    private var variables = [String: String]()

    init(file: File) {
        self.file = file
        count = file.source.count
    }
}

extension Parser {
    func parse() throws -> [String: String] {
        while !isAtEnd {
            start = current
            let character = advance()

            switch character {
            case Token.carriageReturn.rawValue,
                 Token.tab.rawValue,
                 Token.whitespace.rawValue:
                skip()
            case Token.comment.rawValue:
                skipUntilNewline()
            case Token.newline.rawValue:
                nextLine()
            default:
                if isAlpha(character) {
                    try addVariable()
                } else {
                    throw syntaxError(
                        .invalidVariableName(character),
                        filePath: file.path,
                        line: line,
                        column: column
                    )
                }
            }
        }

        return variables
    }

    private func addVariable() throws {
        advanceWhileAlphaNumeric()
        let name = substring(from: start, to: current)
        start = current
        skipWhileNeeded()

        if peek() == Token.equal.rawValue {
            skip()
            skipWhileNeeded()

            if peek() == Token.quote.rawValue {
                advance()
                try advanceUntilQuoteOrRaiseError()
                advance()
                variables[name] = substring(from: start + 1, to: current - 1)
            } else {
                advanceUntilNewlineOrComment()
                variables[name] = substring(from: start, to: current).trimmingCharacters(in: .whitespaces)
            }
        } else {
            throw syntaxError(.invalidVariableValue(name), filePath: file.path, line: line, column: column)
        }
    }
}

extension Parser {
    private func skip() {
        start += 1
        current = start
        column += 1
    }

    private func skipUntilNewline() {
        while peek() != Token.newline.rawValue, !isAtEnd {
            skip()
        }
    }

    private func skipWhileNeeded() {
        let characters = [
            Token.carriageReturn.rawValue,
            Token.tab.rawValue,
            Token.whitespace.rawValue
        ]

        while characters.contains(peek()) {
            skip()
        }
    }

    private func nextLine() {
        skip()
        line += 1
        column = 0
    }

    @discardableResult
    private func advance() -> String {
        current += 1
        column += 1

        return character(at: current - 1)
    }

    private func advanceUntilQuoteOrRaiseError() throws {
        while peek() != Token.quote.rawValue, !isAtEnd {
            advance()
        }

        if isAtEnd {
            throw syntaxError(.unterminatedString, filePath: file.path, line: line, column: column)
        }
    }

    private func advanceWhileAlphaNumeric() {
        while isAlphaNumeric(peek()) {
            advance()
        }
    }

    private func advanceUntilNewlineOrComment() {
        while peek() != Token.newline.rawValue, peek() != Token.comment.rawValue, !isAtEnd {
            advance()
        }
    }

    private func isAlpha(_ character: String) -> Bool {
        (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") || character == "_"
    }

    private func isAlphaNumeric(_ character: String) -> Bool {
        isAlpha(character) || isNumeric(character)
    }

    private func isNumeric(_ character: String) -> Bool {
        Int(character) != nil
    }

    private func peek() -> String {
        current >= count ? Token.eof.rawValue : character(at: current)
    }

    private func character(at index: Int) -> String {
        substring(from: index, to: index + 1)
    }

    private func substring(from start: Int, to end: Int) -> String {
        let source = file.source
        let lowerBound = source.index(source.startIndex, offsetBy: start)
        let upperBound = source.index(source.startIndex, offsetBy: end)
        let range = lowerBound ..< upperBound

        return String(source[range])
    }
}
