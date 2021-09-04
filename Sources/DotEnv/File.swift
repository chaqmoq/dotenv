/// A representation of an environment file.
public struct File: CustomStringConvertible, ExpressibleByStringLiteral {
    /// A content of an environment file.
    public let source: String

    /// An absolute path to an environment file in the file system. Defaults to `nil`.
    public let path: String?

    /// See `CustomStringConvertible`.
    public var description: String { source }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral source: String) {
        self.source = source
        path = nil
    }

    /// Initializes a new instance with the `source` and optionally `path` parameters.
    ///
    /// - Parameters:
    ///   - source: A content of an environment file.
    ///   - path: An absolute path to an environment file in the file system. Defaults to `nil`.
    public init(_ source: String, path: String? = nil) {
        self.source = source
        self.path = path
    }
}

extension File: Hashable {
    /// See `Hashable`.
    public func hash(into hasher: inout Hasher) {
        if let path = path {
            hasher.combine(path)
        } else {
            hasher.combine(source)
        }
    }
}
