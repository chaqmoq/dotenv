import Foundation

/// A representation of an error that can occur when an environment file being loaded either doesn't exist or is not UTF8 encodable.
public struct FileError: LocalizedError, Equatable {
    /// An absolute path to a file where an error occurs. Defaults to `nil` if an instance of `File` is created without a path.
    public let filePath: String?

    /// See `LocalizedError`.
    public var errorDescription: String? { message }

    private(set) var message: String

    init(_ errorType: ErrorType, filePath: String? = nil) {
        self.init(errorType.message, filePath: filePath)
    }

    init(_ message: String? = nil, filePath: String? = nil) {
        self.filePath = filePath
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }

        if let filePath = filePath {
            self.message = "[File: \"\(filePath)\"] " + self.message
        }
    }
}

/// A representation of a syntax error thrown when the content of an environment file being parsed and validated is invalid.
public struct SyntaxError: LocalizedError, Equatable {
    /// An absolute path to a file where an error occurs. Defaults to `nil` if an instance of `File` is created without a path.
    public let filePath: String?

    /// A line to a file where an error occurs.
    public let line: Int
    /// A column to a file where an error occurs.
    public let column: Int

    /// See `LocalizedError`.
    public var errorDescription: String? { message }

    private(set) var message: String

    init(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) {
        self.init(errorType.message, filePath: filePath, line: line, column: column)
    }

    init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
        self.filePath = filePath
        self.line = line
        self.column = column
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }

        if let filePath = filePath {
            self.message = "[File: \"\(filePath)\", Line: \(line), Column: \(column)] " + self.message
        } else {
            self.message = "[Line: \(line), Column: \(column)] " + self.message
        }
    }
}

/// A collection of all error types that can occur.
public enum ErrorType: LocalizedError {
    /// Fired when an environment file is not UTF8 encodable.
    case fileMustBeUTF8Encodable

    /// Fired when an environment file can't be found in the file system.
    case fileNotFound

    /// Fired when the name of an environment variable has an invalid character.
    case invalidVariableName(_ character: String)

    /// Fired when the value of an environment variable is invalid.
    case invalidVariableValue(_ variable: String)

    case unknownedError

    /// Fired when the value of an environment variable is not closed with double quotes.
    case unterminatedString

    /// See `LocalizedError`.
    public var errorDescription: String? { message }

    var message: String {
        switch self {
        case .fileMustBeUTF8Encodable: return "An environment file must be UTF8 encodable."
        case .fileNotFound: return "An environment file is not found."
        case .invalidVariableName(let character):
            return """
            An invalid character "\(character)" in a variable. A variable must be alphanumeric and must start with \
            a letter.
            """
        case .invalidVariableValue(let variable):
            return """
            A variable "\(variable)" must have a value or a suffix "\(Token.equal.rawValue)" to denote its value is \
            empty.
            """
        case .unknownedError: return "An unknown error."
        case .unterminatedString: return "An unterminated string."
        }
    }
}

func fileError(_ errorType: ErrorType, filePath: String? = nil) -> FileError {
    FileError(errorType, filePath: filePath)
}

func syntaxError(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) -> SyntaxError {
    SyntaxError(errorType, filePath: filePath, line: line, column: column)
}
