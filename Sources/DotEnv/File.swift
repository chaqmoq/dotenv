/// A representation of an environment file.
public struct File: CustomStringConvertible, Equatable, ExpressibleByStringLiteral {
    /// A content of a file.
    public let source: String

    /// An absolute path to a file in the file system.
    public let path: String?

    /// See `ExpressibleByStringLiteral`.
    public var description: String { source }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral source: String) {
        self.source = source
        path = nil
    }

    /// Initializes a new instance with the `source` and optionally `path` parameters.
    ///
    /// - Parameters:
    ///   - source: A content of a file.
    ///   - path: An absolute path to a file in the file system. Defaults to `nil`.
    public init(_ source: String, path: String? = nil) {
        self.source = source
        self.path = path
    }
}
