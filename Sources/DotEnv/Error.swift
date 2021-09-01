import Foundation

public struct FileError: LocalizedError, Equatable {
    public let filePath: String?
    private(set) var message: String
    public var errorDescription: String? { message }

    public init(_ errorType: ErrorType, filePath: String? = nil) {
        self.init(errorType.message, filePath: filePath)
    }

    public init(_ message: String? = nil, filePath: String? = nil) {
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

public struct SyntaxError: LocalizedError, Equatable {
    public let filePath: String?
    private(set) var message: String
    public let line: Int
    public let column: Int
    public var errorDescription: String? { message }

    public init(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) {
        self.init(errorType.message, filePath: filePath, line: line, column: column)
    }

    public init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
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

public enum ErrorType: CustomStringConvertible {
    case unknownedError

    // FileError
    case fileNotFound
    case fileMustBeUTF8Encodable

    // SyntaxError
    case invalidVariable(_ variable: String)
    case unterminatedString

    public var description: String { message }

    public var message: String {
        switch self {
        case .unknownedError: return "An unknown error."

        // FileError
        case .fileNotFound: return "An environment file is not found."
        case .fileMustBeUTF8Encodable: return "An environment file must be UTF8 encodable."

        // SyntaxError
        case .invalidVariable(let variable):
            return "An invalid variable `\(variable)`. A variable must be alphanumeric and must start with a letter."
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
